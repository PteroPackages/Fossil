require "colorize"
require "option_parser"
require "./commands/**"
require "./logger.cr"
require "./models.cr"
require "./requests.cr"
require "./xml.cr"

module Fossil
  VERSION = "0.2.0"

  Colorize.on_tty_only!

  struct CmdOptions
    property debug : Bool
    property trace : Bool

    def initialize(@debug = false, @trace = false)
    end
  end

  def self.send_help
    STDOUT << <<-HELP
    Usage:
        fossil [options] <command> [args]

    Commands:
        create    creates a new archive
        compare   compares the current archives
        restore   restores (or decompresses) an archive
        prune     removes archives matching a filter
        delete    removes a specified archive
        config    manages the fossil config
        version   shows the current version

    Options:
        --debug         logs debug messages
        --trace         traces error sources
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
      parser.on("--no-color", "disables color for logs") { Colorize.enabled = false }
      parser.on("-h", "--help", "sends help!") { send_help }
      parser.on("-v", "--version", "shows the current version") do
        puts "Fossil #{VERSION}"
        exit 0
      end

      parser.invalid_option {}
      parser.unknown_args do |args, _|
        self.send_help unless args[0]?

        case args[0]
        when "create"
          Commands::Create.new args[1..], opts
        when "compare"
          # TODO
          exit
        when "restore"
          Commands::Restore.new args[1..], opts
        when "prune"
          # TODO
          exit
        when "delete"
          Commands::Delete.new args[1..], opts
        when "config"
          Commands::Config.new args[1..], opts
        when "version"
          puts "Fossil #{VERSION}"
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
