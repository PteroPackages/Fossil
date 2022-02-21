require "yaml"

module Fossil
  class ConfigError < Exception
  end

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
      path = ENV.fetch("FOSSIL_PATH") {
        raise ConfigError.new "environment variable 'FOSSIL_PATH' not set"
      }

      unless File.exists? path
        raise ConfigError.new "environment variable 'FOSSIL_PATH' is an invalid path"
      end

      File.open(path) { |file| new YAML.parse(file) }
    end
  end
end
