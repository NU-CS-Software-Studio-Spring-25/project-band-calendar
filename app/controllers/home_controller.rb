class HomeController < ApplicationController
  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @venues = Venue.joins(:events).where("date(events.date) = ?", @date).order(:name).distinct
    @events_by_venue = {}
    
    @venues.each do |venue|
      @events_by_venue[venue.id] = venue.events
                                        .where("date(date) = ?", @date)
                                        .includes(band_events: :band)
                                        .order(:date)
    end
  end
end 