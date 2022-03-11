require "crest"

module Fossil
  class Request
    @domain : String
    @@headers = {
      "User-Agent" => "Fossil v#{VERSION}",
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }

    def initialize(config)
      @domain = config.domain
      @@headers["Authorization"] = "Bearer " + config.auth
    end

    def self.configure(config)
      new config
    end

    def get(path : String) : String
      res = Crest.get(@domain + path, headers: @@headers)
      res.body
    end

    def loop_get(path : String) : Array(String)
      total_res = [] of String

      body = get path
      total_res << body
      res = Models::Response.from_json body
      if meta = res.meta
        return total_res if meta.current_page == meta.total_pages
        total_res.concat loop_get get_page_no(path)
      end

      total_res
    end

    def get_page_no(path : String)
      _, page = path.split "?"
      return "?page=2" if page.empty?
      return "?page=" + (page[5].to_i + 1).to_s
    end
  end
end
