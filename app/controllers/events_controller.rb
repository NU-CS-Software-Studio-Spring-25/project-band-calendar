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
  end
end
