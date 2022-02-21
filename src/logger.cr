require "colorize"

module Fossil
  class Logger
    getter stack : Array(String)
    getter color : Bool

    def initialize(use_color : Bool)
      @stack = [] of String
      @color = Colorize.enabled? ? use_color : false
    end

    def info(message)
      message = "info: " + message
      @stack << Time.utc.to_s "%D %T - #{message}"

      if @color
        message = message[..3].colorize(:blue).to_s + message[4..]
      end

      STDOUT.puts message
    end

    def warn(message)
      message = "warn: " + message
      @stack << Time.utc.to_s "%D %T - #{message}"

      if @color
        message = message[..3].colorize(:yellow).to_s + message[4..]
      end

      STDOUT.puts message
    end

    def error(messages : Array(String))
      messages = messages.map { |m| "error: " + m }
      messages.each do |message|
        @stack << Time.utc.to_s "%D %T - #{message}"
      end

      if @color
        puts messages.map { |m| m[..4].colorize(:red).to_s + m[5..] }.join("\n")
      else
        puts messages.join "\n"
      end
    end

    def error(message : String)
      error [message]
    end

    def fatal(err)
      error err
      exit 1
    end
  end
end
