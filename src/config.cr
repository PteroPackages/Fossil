module Fossil
  class Config
    property url : String
    property key : String

    def self.archive_path : Path
      {% if flag?(:win32) %}
        Path[ENV["APPDATA"]] / "Fossil" / "Archives"
      {% else %}
        Path["/lib/fossil/archives"]
      {% end %}
    end

    def self.cache_path : Path
      {% if flag?(:win32) %}
        Path[ENV["APPDATA"]] / "Fossil" / "Cache"
      {% else %}
        Path["/lib/fossil/cache"]
      {% end %}
    end

    def self.config_path : Path
      {% if flag?(:win32) %}
        Path[ENV["APPDATA"]] / "Fossil" / "fossil.cfg"
      {% else %}
        Path["/etc/fossil.conf"]
      {% end %}
    end

    def self.write_template : Nil
      File.write config_path, <<-CFG
      # This is a really basic config file setup for Fossil
      # as it only requires the panel URL and API key to
      # operate.

      # The first line MUST be the panel domain:
      https://pterodactyl.domain

      # The second line MUST be the API key. Fossil only
      # supports the use of client API keys:
      ptlc_your_api_key_here

      # Any additional lines will be ignored by Fossil
      so you can store additional information here if
      you want.
      CFG
    end

    def self.fetch
      data = File.read(config_path)
        .lines
        .reject(&.starts_with? '#')
        .reject(&.empty?)

      raise Error.new :config_not_set unless data.size >= 2

      url, key = data[0], data[1]
      URI.parse(url) rescue raise Error.new :config_invalid_url
      raise Error.new :config_invalid_key unless key[0..4] == "ptlc_"

      new data[0], data[1]
    end

    def initialize(@url, @key)
    end

    def save : Nil
      File.write self.class.config_path, "#{@url}\n#{@key}"
    end
  end
end
