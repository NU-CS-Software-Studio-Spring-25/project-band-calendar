class SpotifyController < ApplicationController
  def search_artists
    query = params[:query]
    
    if query.present?
      service = SpotifyService.new
      artists = service.search_artists(query)
      
      render json: artists
    else
      render json: []
    end
  end

  def get_artist_info
    spotify_id = params[:spotify_id]
    
    if spotify_id.present?
      service = SpotifyService.new
      artist_info = service.get_artist_info(spotify_id)
      
      if artist_info
        # Check if band already exists
        band = Band.find_or_initialize_by(name: artist_info[:name])
        
        unless band.persisted?
          # Only update if band is new or doesn't have these attributes
          band.photo_url = artist_info[:image_url]
          band.bio = artist_info[:bio]
          band.save
        end
        
        render json: { 
          band_id: band.id,
          name: band.name,
          photo_url: band.photo_url,
          bio: band.bio
        }
      else
        render json: { error: "Artist not found" }, status: :not_found
      end
    else
      render json: { error: "Spotify ID is required" }, status: :bad_request
    end
  end
end 