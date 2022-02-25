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
  end
end
