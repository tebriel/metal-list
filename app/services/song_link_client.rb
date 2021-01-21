# frozen_string_literal: true

class SongLinkClient
  class << self
    def album_mbid(name)
      # ?query=name:City%20of%20Evil%20Avenged%20Sevenfold&fmt=json&limit=1
      uri = URI('http://musicbrainz.org/ws/2/annotation/')
      uri.query = {
        fmt: 'json',
        limit: 1,
        query: "name:#{name}"
      }.to_query

      # Create client
      http = Net::HTTP.new(uri.host, uri.port)

      # Create Request
      req =  Net::HTTP::Get.new(uri, {
        'User-Agent' => 'python-musicbrainz/0.7.3',
      })

      # Fetch Request
      res = http.request(req)
      json = JSON.parse(res.body)
      json["annotations"].first&.dig("entity")
    rescue StandardError => e
      puts "HTTP Request failed (#{e.message})"
    end

    def cover_art(mbid)
      uri = URI("http://coverartarchive.org/release/#{mbid}")

      # Fetch Request
      res = fetch(uri)
      json = JSON.parse(res.body)
      json["images"].first&.dig("image")
    rescue StandardError => e
      puts "HTTP Request failed (#{e.message})"
    end

    private

    def fetch(url, limit = 10)
      # You should choose better exception.
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0

      req = Net::HTTP::Get.new(url.path, { 
        "Accept" => "application/json",
        'User-Agent' => 'python-musicbrainz/0.7.3',
      })

      response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') { |http| http.request(req) }
      case response
      when Net::HTTPSuccess     then response
      when Net::HTTPRedirection then fetch(URI(response['location']), limit - 1)
      else
        response.error!
      end
    end
  end
end
