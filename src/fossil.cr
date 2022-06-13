require "option_parser"
require "./commands/*"
require "./http.cr"
require "./log.cr"

module Fossil
  VERSION = "0.3.0"

  # :nodoc:
  def self.send_help
    puts <<-HELP
    A Pterodactyl Archive Manager

    Usage:
        fossil [flags...] <command> [args]

    Commands:
        list      list available backups
        get       download tools for backups
        status    get status information on a backup
        create    create a backup on a server
        restore   restore backups on a server
        delete    delete existing backups
        config    fossil config control

    Options:
        -h, --help      send help information
        -v, --version   send the current version
    HELP

    exit
  end

  # :nodoc:
  def self.run
    OptionParser.parse do |parser|
      parser.on("-h", "--help", "send help information") { send_help }
      parser.on("-v", "--version", "send the current version") { puts "fossil version "+ VERSION; exit }
      parser.on("list", "list available backups") { Commands::List.run ARGV[1..] }
      parser.on("get", "download tools for backups") { Commands::Get.run ARGV[1..] }
      parser.on("create", "create a backup on the server") { Commands::Create.run ARGV[1..] }
      parser.on("status", "get status information on a backup") { Commands::Status.run ARGV[1..] }
      parser.on("restore", "restore backups on a server") { Commands::Restore.run ARGV[1..] }
      parser.on("delete", "delete existing backups") { Commands::Delete.run ARGV[1..] }
      parser.on("config", "fossil config control") { Commands::Config.run ARGV[1..] }

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
