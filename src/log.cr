require "colorize"

module Fossil::Log
  # We need this for some reason
  Colorize.on_tty_only!

  @@stack = [] of String

  # Adds the log to the track stack.
  def self.add(data : String)
    @@stack << Time.utc.to_s "%s: #{data}"
  end

  {% for level, color in {
    "info" => :blue,
    "notice" => :cyan,
    "warn" => :yellow,
    "error" => :red
  } %}
  # Writes a {{level.id}} log to the standard output stream, or standard error
  # stream for error/fatal logs.
  def self.{{level.id}}(data : String)
    self.add data
    {% if level.id == "error" %}
    STDERR.puts "#{{{level}}.colorize({{color}})}: #{data}"
    {% else %}
    STDOUT.puts "#{{{level}}.colorize({{color}})}: #{data}"
    {% end %}
  end

  # :ditto:
  def self.{{level.id}}(data : Array(String))
    data.each { |d| self.{{level.id}} d }
  end
  {% end %}

  # Writes an error log to the standard error stream then terminates the
  # process (exit code: 1).
  def self.fatal(data : String)
    self.add data
    STDERR.puts "#{"error".colorize(:red)}: #{data}"
    self.try_save
  end

  # :ditto:
  def self.fatal(data : Array(String))
    data.each do |d|
      self.add d
      STDERR.puts "#{"error".colorize(:red)}: #{d}"
    end
    self.try_save
  end

  # :ditto:
  def self.fatal(err : Exception)
    STDERR.puts "#{"error".colorize(:red)}: #{err.message || "unknown error"}"
    if trace = err.backtrace
      trace.each do |line|
        self.add line
        STDERR.puts "#{"error".colorize(:red)}: #{line}"
      end
    end
    self.try_save
  end

  # :hidden:
  def self.try_save
    # TODO
    exit 1
  end
end
