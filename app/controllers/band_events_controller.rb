# BandEventsController manages the relationship between bands and events.
# It allows adding, updating, and removing set times for bands in events.
#
# == Actions
# * create   - Adds a band to an event with optional set time and notes
# * update   - Modifies a band's performance details in an event
# * destroy  - Removes a band from an event
#
class BandEventsController < ApplicationController
  before_action :set_band_event, only: [ :update, :destroy ]

  # POST /band_events
  # Creates a new band-event association with optional set details.
  #
  # Redirects:
  # - On success: to the associated event with success notice
  # - On failure: to the event with alert
  def create
    @band_event = BandEvent.new(band_event_params)

    if @band_event.save
      redirect_to @band_event.event, notice: "Band set time was successfully added."
    else
      redirect_to @band_event.event, alert: "Could not add band set time."
    end
  end

  # PATCH/PUT /band_events/:id
  # Updates the set time, order, or notes for a band in an event.
  #
  # Redirects:
  # - On success: to the associated event with success notice
  # - On failure: to the event with alert
  def update
    if @band_event.update(band_event_params)
      redirect_to @band_event.event, notice: "Band set time was successfully updated."
    else
      redirect_to @band_event.event, alert: "Could not update band set time."
    end
  end

  # DELETE /band_events/:id
  # Removes a band from the associated event.
  #
  # Redirects:
  # - Always redirects to the event with success notice
  def destroy
    event = @band_event.event
    @band_event.destroy

    redirect_to event, notice: "Band was successfully removed from the event."
  end

  private

  # Finds the BandEvent by ID for update and destroy actions.
  def set_band_event
    @band_event = BandEvent.find(params[:id])
  end

  # Strong parameters for creating and updating band-event associations.
  def band_event_params
    params.require(:band_event).permit(:band_id, :event_id, :start_time, :end_time, :set_position, :notes)
  end
end
