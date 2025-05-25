require 'rspotify'

class SpotifyService
  def initialize
    # Configure RSpotify with Spotify API credentials
    RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
  end

  def search_artists(name, limit = 10)
    return [] if name.blank?
    
    # Search for artists with the given name - use a higher limit to get more results that we'll sort
    artists = RSpotify::Artist.search(name, limit: limit)
    
    # Format results for our application
    formatted_artists = artists.map do |artist|
      {
        name: artist.name,
        spotify_id: artist.id,
        url: artist.external_urls['spotify'],
        image_url: get_image_url(artist),
        popularity: artist.popularity
      }
    end
    
    # Sort by popularity (descending) and take the top 5
    formatted_artists.sort_by { |artist| -artist[:popularity] }.take(5)
  rescue => e
    Rails.logger.error("Spotify artist search error: #{e.message}")
    []
  end

  def get_artist_info(spotify_id)
    return nil if spotify_id.blank?
    
    # Get full artist details
    artist = RSpotify::Artist.find(spotify_id)
    
    # Get artist's top tracks for bio-like content
    top_tracks = artist.top_tracks('US').map(&:name).join(", ")
    
    # Get artist's genres for additional info
    genres = artist.genres.join(", ")
    
    # Create a bio from available information
    bio = "#{artist.name} is a music artist"
    bio += " known for songs like #{top_tracks}" if top_tracks.present?
    bio += ". Genres: #{genres}" if genres.present?
    bio += "."
    
    {
      name: artist.name,
      spotify_id: artist.id,
      url: artist.external_urls['spotify'],
      image_url: get_image_url(artist),
      bio: bio,
      popularity: artist.popularity,
      genres: artist.genres
    }
  rescue => e
    Rails.logger.error("Spotify artist info error: #{e.message}")
    nil
  end

  private

  def get_image_url(artist)
    # Get the largest available image
    if artist.images.present?
      artist.images.first['url']
    else
      # Fallback image if none available
      "https://via.placeholder.com/300"
    end
  end
end 