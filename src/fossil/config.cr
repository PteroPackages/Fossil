require "yaml"
require "./errors.cr"

module Fossil
  class Config
    property domain : String
    property auth   : String
    property format : String

    def initialize(data)
      @domain = data["domain"].to_s
      @auth = data["auth"].to_s
      @format = data["format"].to_s
    end

    def self.from_env : self
      raise Errors::EnvNotSetError.new unless ENV["FOSSIL_PATH"]?
      raise Errors::InvalidEnvError.new unless File.exists? ENV["FOSSIL_PATH"]

      File.open(ENV["FOSSIL_PATH"]) { |file| new YAML.parse(file) }
    end

    def self.from_local : self
      fp = Path.new(Dir.current).join ".fossil.yml"
      File.open(fp) { |file| new YAML.parse(file) }
    end
  end
end
