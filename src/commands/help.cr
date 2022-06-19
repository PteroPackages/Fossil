require "option_parser"

module Fossil::Commands
  struct HelpSpec
    property info : Array(String)
    property flags : Hash(String, Array(String))

    def initialize
      @info = [] of String
      @flags = {} of String => Array(String)
    end
  end

  # Sends detailed help information on commands and flags.
  class Help
    # :nodoc:
    def self.send_help
      puts <<-HELP
      Sends detailed help information on commands and flags.

      Usage:
          fossil help <command> [flag]

      Arguments:
          command     the command to get help for

      Options:
          -h, --help  send help information
      HELP

      exit
    end

    # :nodoc:
    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("config", "send help for the config command") { config_help }
        parser.on("-h", "--help", "send help information") { send_help }
      end
    end

    {% for cmd in %w(list get status create restore delete config) %}
    # Gets help for the {{cmd.id}} command.
    def self.{{cmd.id}}_help
      spec = {{cmd.titleize.id}}.get_spec
      puts spec.info[0] + "\n\n" + spec.info[1..].join('\n') + "\n\nFlags:"
      spec.flags.each_value.with_index do |val, idx|
        puts val.map { |i| " " + i }.join '\n'
        puts '\n' if idx < spec.flags.size - 1
      end
      exit
    end
    {% end %}
  end
end
