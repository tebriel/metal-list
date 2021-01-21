class AddThumbnailUrlToAlbum < ActiveRecord::Migration[6.1]
  def change
    add_column :albums, :thumbnail_url, :string
  end
end
