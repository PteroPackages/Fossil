require "yaml"

module Fossil
  class Config
    property domain     : String
    property auth       : String
    property cache_path : String
    property format     : String

    def initialize(data)
      @domain = data["domain"].to_s
      @auth = data["auth"].to_s
      @cache_path = data["cache_path"].to_s
      @format = data["format"].to_s
    end

    def self.fetch : self
      path = ENV["FOSSIL_PATH"]?

      if path.nil?
        Logger.error "environment variable 'FOSSIL_PATH' not set", true
      end

      file = begin
        File.read path.not_nil!
      rescue
        Logger.error "environment variable 'FOSSIL_PATH' is an invalid path", true
      end

      new YAML.parse(file.not_nil!)
    end
  end
end
