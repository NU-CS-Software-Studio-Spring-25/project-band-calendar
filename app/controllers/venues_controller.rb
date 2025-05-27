class VenuesController < ApplicationController
  def index
    @venues = Venue.page(params[:page]).per(9)  # adjust per-page number as needed
  end

  def show
    @venue = Venue.find(params[:id])
    @upcoming_events = @venue.events.where("date >= ?", Date.today).order(:date)
    @past_events = @venue.events.where("date < ?", Date.today).order(date: :desc)
  end

  def new
    @venue = Venue.new
  end

  def create
    @venue = Venue.new(venue_params)

    if @venue.save
      redirect_to @venue, notice: "Venue was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @venue = Venue.find(params[:id])
  end

  def update
    @venue = Venue.find(params[:id])

    if @venue.update(venue_params)
      redirect_to @venue, notice: "Venue was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

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

  def venue_params
    params.require(:venue).permit(
      :name, :street_address, :city, :state, :postal_code, :country,
      :description, :venue_type, :capacity, :website, :phone, :email,
      :accessible, :all_ages, :has_food, :has_bar
    )
  end
end
