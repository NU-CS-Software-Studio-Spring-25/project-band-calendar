# BandsController manages CRUD operations for bands.
# It allows users to view, create, edit, and delete band records,
# as well as display a band's upcoming events.
#
# == Actions
# * index     - Lists all bands with pagination
# * show      - Shows details of a single band and its upcoming events
# * new       - Displays form to create a new band
# * create    - Creates a band from form input
# * edit      - Displays form to edit a band
# * update    - Updates band attributes
# * destroy   - Deletes a band from the system
#
class BandsController < ApplicationController
  # GET /bands
  # Lists all bands with pagination.
  def index
    @bands = Band.page(params[:page]).per(9)
  end

  # GET /bands/:id
  # Displays a single band and its upcoming events with venue info.
  def show
    @band = Band.find(params[:id])
    @events = @band.events.includes(:venue).where("date >= ?", Date.today).order(date: :asc)
  end

  # GET /bands/new
  # Renders form to create a new band.
  def new
    @band = Band.new
  end

  # POST /bands
  # Creates a new band. Shows error if band name is taken.
  def create
    @band = Band.new(band_params)
    if @band.save
      redirect_to @band, notice: "Band was successfully created."
    else
      if @band.errors[:name].include?("has already been taken")
        flash.now[:alert] = "A band with the name '#{@band.name}' already exists."
      end
      render :new, status: :unprocessable_entity
    end
  end

  # GET /bands/:id/edit
  # Renders form to edit an existing band.
  def edit
    @band = Band.find(params[:id])
  end

  # PATCH/PUT /bands/:id
  # Updates an existing band. Shows alert if name is taken.
  def update
    @band = Band.find(params[:id])
    if @band.update(band_params)
      redirect_to @band, notice: "Band was successfully updated."
    else
      if @band.errors[:name].include?("has already been taken")
        flash.now[:alert] = "A band with the name '#{@band.name}' already exists."
      end
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /bands/:id
  # Deletes a band.
  def destroy
    @band = Band.find(params[:id])
    @band.destroy
    redirect_to bands_path, notice: "Band was successfully deleted.", status: :see_other
  end

  private

  # Strong parameters for band creation and update.
  def band_params
    params.require(:band).permit(:name, :photo_url, :bio)
  end
end
