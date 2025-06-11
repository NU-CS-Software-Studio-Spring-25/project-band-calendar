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

    if params[:lat].present? && params[:lon].present?
      radius = params[:radius] || 10
      @events = Event.joins(:venue).merge(
        Venue.near([ params[:lat], params[:lon] ], radius)
      )
    else
      @events = Event.all
    end

    @events = scope.page(params[:page]).per(3)

    respond_to do |format|
      format.html
      format.json do
        render json: @events.map { |event|
          {
            title: event.name,
            start: event.date.strftime("%Y-%m-%d"),
            venue: event.venue.name
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
