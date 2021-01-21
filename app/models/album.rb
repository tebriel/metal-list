class Album < ApplicationRecord
  belongs_to :artist

  before_save :fetch_art

  def fetch_art
    mbid = SongLinkClient.album_mbid("#{name} #{artist.name}")
    return if mbid.nil?

    self.thumbnail_url = SongLinkClient.cover_art(mbid)
  end
end
