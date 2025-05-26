class BandsController < ApplicationController
  def index
    @bands = Band.page(params[:page]).per(3) # adjust 6 to however many you want per page
  end

  def show
    @band = Band.find(params[:id])
    @events = @band.events
  end

  def new
    @band = Band.new
  end

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

  def edit
    @band = Band.find(params[:id])
  end

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

  def destroy
    @band = Band.find(params[:id])
    @band.destroy
    redirect_to bands_path, notice: "Band was successfully deleted.", status: :see_other
  end

  private

  def band_params
    params.require(:band).permit(:name, :photo_url, :bio)
  end
end
