module Fossil::Config
  CACHE_DIR = begin
    {% if flag?(:win32) %}
      Path[::ENV["LOCALAPPDATA"]] / "fossil"
    {% else %}
      if cache = ::ENV["XDG_CACHE_HOME"]?
        Path[cache] / "fossil"
      else
        Path.home / ".config" / "fossil"
      end
    {% end %}
  end

  LIBRARY_DIR = begin
    {% if flag?(:win32) %}
      Path[ENV["APPDATA"]] / "fossil"
    {% else %}
      if data = ENV["XDG_DATA_HOME"]?
        Path[data] / "fossil"
      else
        Path.home / ".local" / "share" / "fossil"
      end
    {% end %}
  end

  class Error < Exception
  end

  class_property url : String { "" }
  class_property key : String { "" }

  def self.load : Nil
    data = File.read_lines CACHE_DIR / "fossil.conf"
    raise Error.new "Invalid format (url-key)" unless data.size == 2

    uri = URI.parse data[0] rescue raise Error.new "Invalid URL format"
    raise Error.new "Missing URL host/scheme" if uri.host.nil? || uri.scheme.nil?
    raise Error.new "URL should not contain paths" unless uri.path.nil? || uri.path.empty?
    raise Error.new "Invalid API key format (must start with 'ptlc_')" unless data[1].starts_with? "ptlc_"

    @@url, @@key = data
  rescue File::NotFoundError
    raise Error.new "File not found (#{CACHE_DIR / "fossil.conf"})"
  end

  def self.load_unchecked : Nil
    data = File.read_lines CACHE_DIR / "fossil.conf"
    return unless data.size == 2
    @@url, @@key = data
  rescue File::NotFoundError
    raise Error.new "File not found (#{CACHE_DIR / "fossil.conf"})"
  end

  def self.save : Nil
    File.write(CACHE_DIR / "fossil.conf", "#{@@url}\n#{@@key}")
  end
end
