require "colorize"

module Fossil
  module Logger
    @@stack = [] of String
    @@color = true
    @@levels = {
      :blue => "info",
      :yellow => "warn",
      :red => "error",
      :default => "debug"
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

    def self.banner
      STDOUT.puts "Fossil archive manager v#{VERSION}".colorize(:dark_gray).to_s
    end

    {% for color, level in {
      :blue => "info",
      :green => "success",
      :yellow => "warn",
      :default => "debug"
    } %}
    def self.{{ level.id }}(messages : Array(String))
      self.write messages, :{{ color.id }}
    end

    def self.{{ level.id }}(message : String)
      self.write [message], :{{ color.id }}
    end
    {% end %}

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
  end
end
