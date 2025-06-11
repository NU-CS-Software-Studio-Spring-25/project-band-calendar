# SpotifyController handles interaction with the Spotify API for searching artists
# and retrieving detailed artist information.
#
# == Actions
#
# * search_artists - Searches Spotify for artists by name.
# * get_artist_info - Retrieves detailed artist info using a Spotify artist ID.
#
class SpotifyController < ApplicationController
  # GET /spotify/search_artists
  # Searches for artists on Spotify based on a query string.
  #
  # Params:
  # - query: The search term to use for finding artists.
  #
  # Returns:
  # - JSON array of matching artists (or empty array if no query given)
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

  # GET /spotify/get_artist_info
  # Retrieves detailed artist information from Spotify by Spotify ID.
  #
  # Params:
  # - spotify_id: The Spotify artist ID
  #
  # Behavior:
  # - If artist exists in local DB, returns existing band info
  # - If artist doesn't exist, fetches info and creates a new Band record
  #
  # Returns:
  # - JSON object containing band ID, name, image, and bio
  # - Error JSON if not found or ID is missing
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
