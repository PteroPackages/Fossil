require "crest"
require "./log.cr"
require "./models.cr"

module Fossil
  alias M = Models

  class Http
    property domain  : String
    property key     : String
    property headers : Hash(String, String)

    @@codes = {
      400 => ["400: received a bad request, retrying..."],
      401 => ["401: request unauthorized", "make sure you are using the correct api key"],
      403 => ["403: request forbidden", "make sure the api key has the necessary permissions"],
      409 => ["409: request conflicted"]
    }

    def initialize(config)
      @domain = config.domain
      @key = config.key
      @headers = {
        "User-Agent" => "Fossil v#{VERSION}",
        "Authorization" => "Bearer #{@key}",
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
    end

    def request(method, path, body = nil) : String
      req = Crest::Request.new(method, "#{@domain}/api/client#{path}", headers: @headers)
      res = req.execute
      res.body
    end

    private def handle_error(ex : Crest::RequestFailed)
      if msg = @@codes[ex.http_code]
        Log.error msg
        puts ex.response.body
        exit 1
      else
        Log.error "unknown response: #{ex.http_code}"
        Log.fatal [ex.message, *ex.backtrace]
      end
    end

    def test_domain : Nil
      begin
        Crest.get("#{@domain}/api/client", headers: @headers)
      rescue ex : Crest::RequestFailed
        handle_error ex
      end
    end

    def get_backups(id)
      begin
        res = request :get, "/servers/#{id}/backups"
        val = M::DataWrapper(M::ItemWrapper(M::Backup)).from_json res

        val.data.map &.attributes
      rescue ex : Crest::RequestFailed
        return if ex.http_code == 409
        handle_error ex
      end
    end

    def get_servers(access = "")
      query = ""
      unless access.empty?
        query = "?type=" + access
      end

      begin
        res = request :get, "/" + query
        val = M::DataWrapper(M::ItemWrapper(M::Server)).from_json res

        val.data.map &.attributes
      rescue ex : Crest::RequestFailed
        handle_error ex
      end
    end

    def get_server(id)
      begin
        res = request :get, "/servers/#{id}"
        val = M::ItemWrapper(M::Server).from_json res

        val.attributes
      rescue ex : Crest::RequestFailed
        handle_error ex
      end
    end

    def get_download_url(id, uuid)
      begin
        res = request :get, "/servers/#{id}/backups/#{uuid}/download"
        val = M::ItemWrapper(M::SignedUrl).from_json res

        val.attributes.url
      rescue ex : Crest::RequestFailed
        handle_error ex
      end
    end

    def get_download(url)
      copy_headers = @headers.clone
      copy_headers.delete "Content-Type"
      copy_headers.delete "Accept"

      begin
        res = Crest::Request.new(:get, url, headers: copy_headers).execute
        name = res.headers["Content-Disposition"]
          .as(String)
          .split(";")[1]
          .split("=")[1]
          .strip('"')

        size = res.headers["Content-Length"]
          .as(String)
          .to_i32

        dl = M::Download.new name, size
        dl.data = res.body
        dl
      rescue ex : Crest::RequestFailed
        handle_error ex
      end
    end
  end
end
