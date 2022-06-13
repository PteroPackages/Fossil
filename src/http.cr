require "crest"
require "./log.cr"
require "./models.cr"

module Fossil
  alias M = Models

  class Http
    property domain  : String
    property key     : String
    property headers : Hash(String, String)

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
      req = Crest::Request.new(method,
                              "#{@domain}/api/client#{path}",
                              body: body,
                              headers: @headers)

      res = req.execute
      res.body
    end

    private def handle_error(ex : Crest::RequestFailed)
      Log.error ex.message
      exit(1) if ex.response.body.size == 0

      data = Array(M::ApiError).from_json ex.response.body, root: "errors"
      Log.error [
        "#{data.size} error#{data.size > 1 ? "s" : ""} returned:",
        ""
      ]
      data.each_with_index do |err, idx|
        Log.error [err.code + ":", err.detail]
        Log.error("") unless idx == data.size - 1
      end

      exit 1
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

    def create_backup(id, name, locked, ignored)
      data = {"name" => name, "is_locked" => locked, "ignored" => ignored}

      begin
        res = request :post, "/servers/#{id}/backups", data
        val = M::ItemWrapper(M::Backup).from_json res

        val.attributes
      rescue ex : Crest::RequestFailed
        handle_error ex
      end
    end

    def restore_backup(id, uuid)
      begin
        _ = request :post, "/servers/#{id}/backups/#{uuid}/restore"
      rescue ex : Crest::RequestFailed
        handle_error ex
      end
    end

    def delete_backup(id, uuid)
      begin
        request :delete, "/servers/#{id}/backups/#{uuid}"
      rescue ex : Crest::RequestFailed
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
