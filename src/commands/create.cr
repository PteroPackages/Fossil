require "option_parser"

module Fossil::Commands
  # Handles creating backups on servers.
  class Create
    @@server = ""
    @@name : String? = nil
    @@locked = false
    @@ignored = ""

    # :nodoc:
    def self.send_help
      puts <<-HELP
      Handles creating backups on servers.

      Usage:
          fossil create <server> [-n|--name <name>] [-l|--locked]
                                  [-i|--ignored <files>] [-h|--help]

      Arguments:
          server                the identifier of the server

      Options:
          -n, --name <name>     set the name of the archive
          -l, --locked          lock the archive when created
          -i, --ignore <files>  a list of files to ignore (separated by ",")
          -h, --help            send help information
      HELP

      exit
    end

    # :nodoc:
    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("-n <name>", "--name <name>", "set the name of the archive") { |v| @@name = v }
        parser.on("-l", "--locked", "lock the archive when created") { @@locked = true }
        parser.on("-i <files>", "--ignore <files>", %(a list of files to ignore (separated by ","))) { |v| @@ignored = v }
        parser.on("-h", "--help", "send help information") { send_help }

        parser.missing_option { |op| Log.fatal "missing option #{op} <...>" }
        parser.unknown_args do |args, _|
          if args.size == 0
            Log.fatal [
              "missing server identifier to create server on",
              "run 'fossil create --help' for more information"
            ]
          end

          @@server = args[0]
        end
      end

      cfg = Config.read_config
      http = Http.new cfg
      ignore = @@ignored.gsub ',', '\n'

      backup = Http.new(cfg).create_backup @@server, @@name, @@locked, ignore

      Log.info [
        "created new archive",
        "name:        #{backup.name}",
        "uuid:        #{backup.uuid}",
        "size:        #{backup.bytes}",
        "locked:      #{backup.is_locked}",
        "successful:  #{backup.is_successful}"
      ]
      exit
    end
  end
end
