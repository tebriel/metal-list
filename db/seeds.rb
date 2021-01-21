require 'csv'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
CSV.read(Rails.root.join('data', 'bestof.csv'), headers: true).each do |record|
  artist = Artist.find_or_create_by!(name: record["Artist"])
  album = Album.find_or_create_by!(name: record["Album"], year: record["Year"], artist: artist)
  album.position = record["Position"]
  album.save!
end
