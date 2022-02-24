require "colorize"
require "option_parser"
require "./commands/**"
require "./config.cr"
require "./logger.cr"

module Fossil
  VERSION = "0.1.0"

  Colorize.on_tty_only!

  struct CmdOptions
    property debug    : Bool
    property trace    : Bool
    property verbose  : Bool
    property no_color : Bool

    def initialize(@debug = false, @trace = false,
      @verbose = false, @no_color = false)
    end
  end

  def self.send_help!
    puts <<-HELP
    Usage:
        fossil [options] <command> [args]

    Commands:
        create    creates a new archive
        compare   compares the current archives
        export    exports an archive as a zip file
        prune     removes archives matching a filter
        delete    removes a specified archive
        config    manages the fossil config
        version   shows the current version

    Options:
        --debug         logs debug messages
        --trace         traces error sources
        --verbose       enables verbose logging
        --patch         (EX) attempts to patch broken payloads
        --no-color      disables color for logs
        -h, --help      sends help!
        -v, --version   shows the current version
    HELP

    exit 0
  end

  def self.run
    opts = CmdOptions.new

    OptionParser.parse do |parser|
      parser.on("--debug", "logs debug messages") { opts.debug = true }
      parser.on("--trace", "traces error sources") { opts.trace = true }
      parser.on("--verbose", "enables verbose logging") { opts.verbose = true }
      parser.on("--no-color", "disables color for logs") { opts.no_color = true }
      parser.on("-h", "--help", "sends help!") { send_help! }
      parser.on("-v", "--version", "shows the current version") do
        puts "Fossil #{VERSION}"
        exit 0
      end

      parser.unknown_args do |args, options|
        self.send_help! unless args[0]?

        case args[0]
        when "create"
          # TODO
          exit
        when "compare"
          # TODO
          exit
        when "export"
          # TODO
          exit
        when "prune"
          # TODO
          exit
        when "delete"
          # TODO
          exit
        when "config"
          Commands::ConfigSetup.run args[1..], opts
        when "version"
          puts "Fossil #{VERSION}"
          exit 0
        else
          puts "error: unknown command '#{args[0]}'"
          exit 1
        end
      end
    end

    exit 0
  end
end

begin
  Fossil.run
rescue ex
  Fossil::Logger.error ex
end
