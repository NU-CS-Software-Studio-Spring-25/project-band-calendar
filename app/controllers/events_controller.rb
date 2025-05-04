class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
    @bands = @event.bands
  end

  def new
    @event = Event.new
    @bands = Band.all
  end

  def create
    @event = Event.new(event_params)
    
    if @event.save
      # Handle band associations if band_ids are provided
      if params[:event][:band_ids].present?
        params[:event][:band_ids].reject(&:blank?).each do |band_id|
          @event.bands << Band.find(band_id)
        end
      end
      
      redirect_to @event, notice: 'Event was successfully created.'
    else
      # Add flash alert for duplicate event
      if @event.errors[:name].include?('already exists for this date')
        flash.now[:alert] = "An event named '#{@event.name}' already exists on #{@event.date&.strftime('%B %d, %Y')}."
      end
      
      @bands = Band.all
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @event = Event.find(params[:id])
    @bands = Band.all
  end

  def update
    @event = Event.find(params[:id])
    
    if @event.update(event_params)
      # Update band associations
      @event.bands.clear
      if params[:event][:band_ids].present?
        params[:event][:band_ids].reject(&:blank?).each do |band_id|
          @event.bands << Band.find(band_id)
        end
      end
      
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      # Add flash alert for duplicate event
      if @event.errors[:name].include?('already exists for this date')
        flash.now[:alert] = "An event named '#{@event.name}' already exists on #{@event.date&.strftime('%B %d, %Y')}."
      end
      
      @bands = Band.all
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to events_path, notice: 'Event was successfully deleted.', status: :see_other
  end

  private

  def event_params
    params.require(:event).permit(:name, :venue, :location, :date)
  end
end
