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

    def self.fetch
      data = File.read(config_path).lines
      raise Error.new :config_not_set unless data.size >= 2

      url, key = data
      URI.parse(url) rescue raise Error.new :config_invalid_url
      raise Error.new :config_invalid_key unless key[0..4] == "ptlc_"

      new url, key
    end

    def self.default
      new "https://pterodactyl.test", "ptlc_your_ap1_k3y"
    end

    def initialize(@url, @key)
    end

    def save : Nil
      File.write self.class.config_path, "#{@url}\n#{@key}"
    end
  end
end
