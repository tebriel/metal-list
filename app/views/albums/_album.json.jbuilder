json.extract! album, :id, :name, :position, :year, :artist_id, :created_at, :updated_at
json.url album_url(album, format: :json)
