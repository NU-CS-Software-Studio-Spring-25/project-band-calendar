class EventsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :authorize_admin!, only: [ :approve, :disapprove ]

def index
  # Start with base scope (pending or approved)
  scope = params[:pending] && current_user_admin? ? Event.pending : Event.approved

  # Apply month filter if present
  if params[:month].present?
    begin
      date = Date.strptime(params[:month], "%Y-%m")
      scope = scope.where(date: date.beginning_of_month..date.end_of_month)
      flash.now[:notice] = "Showing events for #{date.strftime('%B %Y')}."
    rescue ArgumentError
      flash.now[:alert] = "Invalid month format."
    end
  end

  # Finally, apply pagination to the filtered scope
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



  def show
    @event = Event.find(params[:id])
    @bands = @event.bands
    @band_events = @event.band_events.includes(:band).ordered_by_time
  end

  def new
    @event = Event.new
    @venues = Venue.all.order(:name)
  end

  def create
    @event = Event.new(event_params)
    @event.submitted_by = current_user

    # If user is admin, auto-approve the event
    @event.approved = current_user_admin?

    if @event.save
      # Handle band associations if band_ids are provided
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

      # Add flash alert for duplicate event
      if @event.errors[:name].include?("already exists for this date")
        flash.now[:alert] = "An event named '#{@event.name}' already exists on #{@event.date&.strftime('%B %d, %Y')}."
      end

      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @event = Event.find(params[:id])
    authorize_event_edit!
    @venues = Venue.all.order(:name)
  end

  def update
    @event = Event.find(params[:id])
    authorize_event_edit!

    # If event is being updated by a non-admin, set approved to false
    unless current_user_admin?
      event_params_with_approval = event_params.merge(approved: false)
    else
      event_params_with_approval = event_params
    end

    if @event.update(event_params_with_approval)
      # Update band associations
      @event.band_events.destroy_all
      if params[:event][:band_ids].present?
        process_band_associations
      end

      redirect_to @event, notice: "Event was successfully updated."
    else
      @venues = Venue.all.order(:name)

      # Add flash alert for duplicate event
      if @event.errors[:name].include?("already exists for this date")
        flash.now[:alert] = "An event named '#{@event.name}' already exists on #{@event.date&.strftime('%B %d, %Y')}."
      end

      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event = Event.find(params[:id])
    authorize_event_edit!
    @event.destroy
    redirect_to events_path, notice: "Event was successfully deleted.", status: :see_other
  end

  def approve
    @event = Event.find(params[:id])
    @event.update(approved: true)
    redirect_to @event, notice: "Event has been approved."
  end

  def disapprove
    @event = Event.find(params[:id])
    @event.update(approved: false)
    redirect_to @event, notice: "Event has been unapproved."
  end

  private

  def event_params
    params.require(:event).permit(:name, :venue_id, :date)
  end

  def process_band_associations
    band_times = params[:band_times] || {}

    params[:event][:band_ids].reject(&:blank?).each_with_index do |band_id, index|
      # Default position is index + 1
      position = index + 1

      # Check if we have timing info for this band
      if band_times[band_id].present?
        times = band_times[band_id]

        # Create band_event with timing information
        @event.band_events.create!(
          band_id: band_id,
          set_position: times[:set_position].presence || position,
          start_time: parse_time(times[:start_time]),
          end_time: parse_time(times[:end_time]),
          notes: times[:notes]
        )
      else
        # Create band_event without timing information
        @event.band_events.create!(
          band_id: band_id,
          set_position: position
        )
      end
    end
  end

  def parse_time(time_str)
    return nil if time_str.blank?

    # If the time string already contains the date part, parse directly
    if time_str.include?("T")
      return Time.parse(time_str) rescue nil
    end

    # Otherwise, combine with the event date
    begin
      hour, minute = time_str.split(":").map(&:to_i)
      return nil if hour.nil? || minute.nil?

      # Use event date with the provided time
      event_date = @event.date.to_date
      Time.new(event_date.year, event_date.month, event_date.day, hour, minute)
    rescue
      nil
    end
  end

  def authorize_event_edit!
    unless current_user_admin? || (@event.submitted_by == current_user)
      flash[:alert] = "You don't have permission to edit this event."
      redirect_to @event
    end
  end
end
