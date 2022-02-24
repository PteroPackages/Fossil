require "colorize"

module Fossil
  module Logger
    @@stack = [] of String
    @@color = true
    @@levels = {
      :blue => "info",
      :yellow => "warn",
      :red => "error"
    }

    def self.get_stack
      @@stack
    end

    def self.set_color(value)
      @@color = Colorize.enabled? ? value : false
    end

    def self.write(messages : Array(String), color : Symbol) : Nil
      messages.each { |m| @@stack << Time.utc.to_s "%D %T - #{@@levels[color]}: #{m}" }
      result = ""

      if @@color
        result = messages.map { |m| @@levels[color].colorize(color).to_s + ": #{m}" }.join "\n"
      else
        result = messages.map { |m| "#{@@levels[color]}: #{m}" }.join "\n"
      end

      if color == :red
        STDERR.puts result
      else
        STDOUT.puts result
      end
    end

    def self.info(messages : Array(String))
      self.write messages, :blue
    end

    def self.info(message : String)
      self.write [message], :blue
    end

    def self.warn(messages : Array(String))
      self.write messages, :yellow
    end

    def self.warn(message : String)
      self.write [message], :yellow
    end

    def self.error(messages : Array(String), close : Bool = false)
      self.write messages, :red
      exit(1) if close
    end

    def self.error(message : String, close : Bool = false)
      self.write [message], :red
      exit(1) if close
    end

    def self.error(err : Exception)
      self.write [err.message || "unknown error"], :red
      self.write err.backtrace.not_nil!, :red
      exit 1
    end

    def self.debug(messages : Array(String))
      self.write messages, :reset
    end

    def self.debug(message : String)
      self.write [message], :reset
    end
  end
end
