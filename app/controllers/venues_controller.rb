# VenuesController manages the creation, viewing, editing, and deletion of venues.
#
# == Actions
#
# * index - Lists all venues with pagination.
# * show - Displays a single venue with upcoming and past events.
# * new - Displays a form for creating a new venue.
# * create - Handles submission of the new venue form.
# * edit - Displays a form for editing an existing venue.
# * update - Handles submission of the venue edit form.
# * destroy - Deletes a venue unless it has associated events.
#
class VenuesController < ApplicationController
  # GET /venues
  # Lists venues with pagination.
  def index
    @venues = Venue.page(params[:page]).per(9)  # adjust per-page number as needed
  end

  # GET /venues/:id
  # Displays a single venue along with its upcoming and past events.
  def show
    @venue = Venue.find(params[:id])
    @upcoming_events = @venue.events.where("date >= ?", Date.today).order(:date)
    @past_events = @venue.events.where("date < ?", Date.today).order(date: :desc)
  end

  # GET /venues/new
  # Renders form for a new venue.
  def new
    @venue = Venue.new
  end

  # POST /venues
  # Creates a new venue if valid.
  def create
    @venue = Venue.new(venue_params)

    if @venue.save
      redirect_to @venue, notice: "Venue was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /venues/:id/edit
  # Renders form to edit an existing venue.
  def edit
    @venue = Venue.find(params[:id])
  end

  # PATCH/PUT /venues/:id
  # Updates an existing venue if valid.
  def update
    @venue = Venue.find(params[:id])

    if @venue.update(venue_params)
      redirect_to @venue, notice: "Venue was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /venues/:id
  # Deletes a venue unless it has associated events.
  def destroy
    @venue = Venue.find(params[:id])

    if @venue.events.exists?
      redirect_to @venue, alert: "Cannot delete venue with associated events.", status: :unprocessable_entity
    else
      @venue.destroy
      redirect_to venues_path, notice: "Venue was successfully deleted.", status: :see_other
    end
  end

  private

  # Strong parameters for creating/updating venues.
  def venue_params
    params.require(:venue).permit(
      :name, :street_address, :city, :state, :postal_code, :country,
      :description, :venue_type, :capacity, :website, :phone, :email,
      :accessible, :all_ages, :has_food, :has_bar
    )
  end
end
