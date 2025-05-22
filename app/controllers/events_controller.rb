class EventsController < ApplicationController
  def index
    @events = Event.all
  
    respond_to do |format|
      format.html  # 正常 HTML 页面显示
      format.json do  # 这个是给 FullCalendar 用的
        render json: @events.map { |event|
          {
            title: event.name,
            start: event.date.strftime("%Y-%m-%d")
          }
        }
      end
    end
  end

  def show
    @event = Event.find(params[:id])
    @bands = @event.bands
  end

  def new
    @event = Event.new
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
      
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @event = Event.find(params[:id])
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
