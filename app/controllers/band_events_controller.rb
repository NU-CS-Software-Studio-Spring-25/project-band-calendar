class BandEventsController < ApplicationController
  before_action :set_band_event, only: [:update, :destroy]
  
  def create
    @band_event = BandEvent.new(band_event_params)
    
    if @band_event.save
      redirect_to @band_event.event, notice: 'Band set time was successfully added.'
    else
      redirect_to @band_event.event, alert: 'Could not add band set time.'
    end
  end
  
  def update
    if @band_event.update(band_event_params)
      redirect_to @band_event.event, notice: 'Band set time was successfully updated.'
    else
      redirect_to @band_event.event, alert: 'Could not update band set time.'
    end
  end
  
  def destroy
    event = @band_event.event
    @band_event.destroy
    
    redirect_to event, notice: 'Band was successfully removed from the event.'
  end
  
  private
  
  def set_band_event
    @band_event = BandEvent.find(params[:id])
  end
  
  def band_event_params
    params.require(:band_event).permit(:band_id, :event_id, :start_time, :end_time, :set_position, :notes)
  end
end 