require "option_parser"
require "./commands/*"
require "./http.cr"
require "./log.cr"

module Fossil
  VERSION = "0.3.0"

  def self.send_help
    puts <<-HELP
    Usage:
        fossil [flags] <command> [args]

    Commands:
        list
        get
        create
        restore
        delete
        help
        config

    Options:
        -h, --help
        -v, --version
    HELP

    exit
  end

  def self.run
    OptionParser.parse do |parser|
      parser.on("-h", "--help", "sends help information") { send_help }
      parser.on("-v", "--version", "sends the fossil version") { puts "fossil version "+ VERSION; exit }
      parser.on("config", "config management commands") { Commands::Config.run ARGV[1..] }
      parser.on("list", "lists all server backups") { Commands::List.run ARGV[1..] }

      parser.unknown_args do |args, _|
        send_help if args.empty?
        Log.fatal [
          "unknown option '#{args.join}'",
          "run 'fossil --help' for more information"
        ]
      end
    end
  end
end

begin
  Fossil.run
rescue ex
  Fossil::Log.fatal ex
end
