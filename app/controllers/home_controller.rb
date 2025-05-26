class HomeController < ApplicationController
  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    
    # Only include venues that have approved events for this date
    @venues = Venue.joins(:events)
                  .where("date(events.date) = ? AND events.approved = ?", @date, true)
                  .order(:name).distinct
    
    @events_by_venue = {}
    
    @venues.each do |venue|
      @events_by_venue[venue.id] = venue.events
                                        .where("date(date) = ? AND approved = ?", @date, true)
                                        .includes(band_events: :band)
                                        .order(:date)
    end
    
    # Count pending events (only visible to admins)
    if current_user_admin?
      @pending_events_count = Event.pending.where("date(date) = ?", @date).count
    end
  end
end 