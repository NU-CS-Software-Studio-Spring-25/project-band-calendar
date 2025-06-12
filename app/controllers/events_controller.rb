# EventsController handles the creation, display, approval, editing,
# and deletion of events. It supports filtering by date and location,
# pagination, and JSON rendering for integration.
#
# == Filters
# * +authenticate_user!+ – required for all actions except :index and :show
# * +authorize_admin!+ – required for :approve and :disapprove actions
#
# == Actions
# * index        - Lists events (approved or pending), supports filters and pagination
# * show         - Shows details of a specific event including its bands
# * new          - Renders form to create a new event
# * create       - Saves a new event to the database
# * edit         - Renders form to edit an existing event
# * update       - Updates an existing event
# * destroy      - Deletes an event
# * approve      - Approves a submitted event (admin only)
# * disapprove   - Unapproves an event (admin only)
#
require 'prawn'
class EventsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :authorize_admin!, only: [ :approve, :disapprove ]

  # GET /events
  # Displays approved or pending events, optionally filtered by month or location.
  # Renders HTML or JSON.
  def index
    scope = params[:pending] && current_user_admin? ? Event.pending : Event.approved

    if params[:month].present?
      begin
        date = Date.strptime(params[:month], "%Y-%m")
        scope = scope.where(date: date.beginning_of_month..date.end_of_month)
        flash.now[:notice] = "Showing events for #{date.strftime('%B %Y')}."
      rescue ArgumentError
        flash.now[:alert] = "Invalid month format."
      end
    end

    # Handle FullCalendar date range requests (for JSON format)
    if params[:start].present? && params[:end].present?
      begin
        start_date = Date.parse(params[:start])
        end_date = Date.parse(params[:end])
        scope = scope.where(date: start_date..end_date)
      rescue ArgumentError
        # Invalid date format, ignore and show all events
      end
    end

    if params[:lat].present? && params[:lon].present?
      radius = (params[:radius] || 10).to_f
      lat = params[:lat].to_f
      lon = params[:lon].to_f
      nearby_venue_ids = Venue.near([lat, lon], radius, order: false).pluck(:id)
      @events = Event.includes(:venue).where(venues: { id: nearby_venue_ids })
    else
      @events = Event.all
    end

    # Apply the scope to @events
    @events = @events.merge(scope)
    
    # Apply hidden events filter if user is signed in
    if user_signed_in?
      @events = @events.where.not(id: current_user.hidden_events.select(:id))
    end

    respond_to do |format|
      format.html do
        # Only apply pagination for HTML format
        @events = @events.page(params[:page]).per(3)
      end
      format.json do
        # For JSON (calendar), return all events without pagination
        # Include necessary associations and order by date
        @events = @events.includes(:venue, bands: []).order(:date)
        render json: @events.map { |event|
          {
            id: event.id,
            title: event.name,
            start: event.date.strftime("%Y-%m-%d"),
            url: event_path(event),
            venue: {
              name: event.venue.name,
              city: event.venue.city,
              state: event.venue.state,
              address: event.venue.street_address
            },
            bands: event.bands.map { |band|
              {
                name: band.name,
                photo_url: band.photo_url.present? ? band.photo_url : nil
              }
            },
            formatted_date: event.date.strftime("%A, %B %d, %Y"),
            formatted_time: event.date.strftime("%I:%M %p"),
            pending: event.pending?
          }
        }
      end
    end
  end

  # GET /events/:id
  # Shows a single event, its bands, and band event times.
  def show
    @event = Event.find(params[:id])
    @bands = @event.bands
    @band_events = @event.band_events.includes(:band).ordered_by_time
  end

  # GET /events/new
  # Renders the form to create a new event.
  def new
    @event = Event.new
    @venues = Venue.all.order(:name)
  end

  # POST /events
  # Creates a new event, associates bands, and optionally auto-approves it.
  def create
    @event = Event.new(event_params)
    @event.submitted_by = current_user
    @event.approved = current_user_admin?

    if @event.save
      if params[:event][:band_ids].present?
        process_band_associations
      end

      if @event.approved?
        redirect_to @event, notice: "Event was successfully created."
      else
        redirect_to @event, notice: "Event was submitted and is awaiting approval."
      end
    else
      @venues = Venue.all.order(:name)
      if @event.errors[:name].include?("already exists for this date")
        flash.now[:alert] = "An event named '#{@event.name}' already exists on #{@event.date&.strftime('%B %d, %Y')}."
      end
      render :new, status: :unprocessable_entity
    end
  end

  # GET /events/:id/edit
  # Renders the form to edit an event.
  def edit
    @event = Event.find(params[:id])
    authorize_event_edit!
    @venues = Venue.all.order(:name)
  end

  # PATCH/PUT /events/:id
  # Updates an event and its associated bands.
  def update
    @event = Event.find(params[:id])
    authorize_event_edit!

    event_params_with_approval = current_user_admin? ? event_params : event_params.merge(approved: false)

    if @event.update(event_params_with_approval)
      @event.band_events.destroy_all
      if params[:event][:band_ids].present?
        process_band_associations
      end
      redirect_to @event, notice: "Event was successfully updated."
    else
      @venues = Venue.all.order(:name)
      if @event.errors[:name].include?("already exists for this date")
        flash.now[:alert] = "An event named '#{@event.name}' already exists on #{@event.date&.strftime('%B %d, %Y')}."
      end
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /events/:id
  # Deletes an event.
  def destroy
    @event = Event.find(params[:id])
    authorize_event_edit!
    @event.destroy
    redirect_to events_path, notice: "Event was successfully deleted.", status: :see_other
  end

  # PATCH /events/:id/approve
  # Admin-only action to approve an event.
  def approve
    @event = Event.find(params[:id])
    @event.update(approved: true)
    redirect_to @event, notice: "Event has been approved."
  end

  # PATCH /events/:id/disapprove
  # Admin-only action to unapprove an event.
  def disapprove
    @event = Event.find(params[:id])
    @event.update(approved: false)
    redirect_to @event, notice: "Event has been unapproved."
  end

  def recent_pdf
    one_month_ago = 1.month.ago
    @recent_events = Event.where('date >= ?', one_month_ago).order(:date)
  
    pdf = Prawn::Document.new
    pdf.text "Events in the Past Month", size: 24, style: :bold
    pdf.move_down 20
  
    @recent_events.each do |event|
      pdf.text "Name: #{event.name}"
      pdf.text "Date: #{event.date.strftime('%Y-%m-%d')}"
      pdf.text "Venue: #{event.venue.try(:name)}"
      pdf.move_down 10
    end
  
    send_data pdf.render,
              filename: "recent_events.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end
  

  def hide
    event = Event.find(params[:id])
    current_user.user_hidden_events.find_or_create_by(event: event)
    redirect_to events_path, notice: "Event hidden."
  end
  
  def show_again
    event = Event.find(params[:id])
    hidden_event = current_user.user_hidden_events.find_by(event: event)
    hidden_event&.destroy
    redirect_to events_path, notice: "Event is now visible."
  end


  private

  # Strong parameters for event creation and update.
  def event_params
    params.require(:event).permit(:name, :venue_id, :date)
  end

  # Associates bands and timing info with an event.
  def process_band_associations
    band_times = params[:band_times] || {}

    params[:event][:band_ids].reject(&:blank?).each_with_index do |band_id, index|
      position = index + 1
      if band_times[band_id].present?
        times = band_times[band_id]
        @event.band_events.create!(
          band_id: band_id,
          set_position: times[:set_position].presence || position,
          start_time: parse_time(times[:start_time]),
          end_time: parse_time(times[:end_time]),
          notes: times[:notes]
        )
      else
        @event.band_events.create!(
          band_id: band_id,
          set_position: position
        )
      end
    end
  end

  # Parses time from a string, returns a Time object or nil.
  def parse_time(time_str)
    return nil if time_str.blank?
    return Time.parse(time_str) if time_str.include?("T") rescue nil

    begin
      hour, minute = time_str.split(":").map(&:to_i)
      event_date = @event.date.to_date
      Time.new(event_date.year, event_date.month, event_date.day, hour, minute)
    rescue
      nil
    end
  end

  # Checks if current user is allowed to edit the event.
  def authorize_event_edit!
    unless current_user_admin? || (@event.submitted_by == current_user)
      flash[:alert] = "You don't have permission to edit this event."
      redirect_to @event
    end
  end
end
