require "ecr"
require "yaml"

module Fossil
  class Config
    property domain        : String
    property auth          : String
    property archive_dir   : String
    property file_format   : String
    property export_format : String
    @@debug = false

    def initialize(data)
      @domain = data["api"]["domain"].to_s
      @auth = data["api"]["auth"].to_s
      @archive_dir = data["archive_dir"].to_s
      @file_format = data["formats"]["file"].to_s
      @export_format = data["formats"]["export"].to_s
    end

    def self.fetch : self
      path = ENV["FOSSIL_PATH"]?

      if path.nil?
        Logger.error "environment variable 'FOSSIL_PATH' not set", true
      end

      file = begin
        File.read Path.new path.not_nil!, "config.yml"
      rescue
        Logger.error "environment variable 'FOSSIL_PATH' is an invalid path", true
      end

      new YAML.parse(file.not_nil!)
    end

    def self.log_debug(message)
      return unless @@debug
      Logger.debug message
    end

    def self.init(use_debug)
      @@debug = use_debug

      unless File.exists? "#{__DIR__}/config.tmpl.ecr"
        Logger.error [
          "missing template confir ecr file to continue",
          "please reinstall Fossil to fix this, or manually add the file"
        ], true
      end

      basedir : String
      {% if flag?(:win32) %}
      basedir = "C:\\Program Files\\Fossil"
      {% else %}
      basedir = "~/fossil"
      {% end %}

      log_debug ["creating new Fossil workspace:", basedir]
      Dir.mkdir basedir

      log_debug "rendering config file..."
      tmpl = ECR.render "#{__DIR__}/config.tmpl.ecr"
      path = Path.new basedir, "config.yml"
      File.write path, tmpl

      log_debug "process completed"
    end
  end
end
