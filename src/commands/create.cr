require "option_parser"

module Fossil::Commands
  class Create
    @@server = ""
    @@name : String? = nil
    @@locked = false
    @@ignored = ""

    def self.send_help
      puts <<-HELP
      Usage:
          fossil create [options]

      Options:
          -n, --name <name>
          -l, --locked
          -i, --ignored <path>
          -h, --help
      HELP

      exit
    end

    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("-h", "--help", "sends help information") { send_help }
        parser.on("-n <name>", "--name <name>", "set the name for the archive") { |v| @@name = v }
        parser.on("-l", "--locked", "lock the new archive") { @@locked = true }
        parser.on("-i <path>", "--ignored <path>", "") { |v| @@ignored = v }

        parser.missing_option { |op| Log.fatal "missing option #{op} <...>" }
        parser.unknown_args do |args, _|
          if args.size == 0
            Log.fatal [
              "missing server identifier to create server on",
              "run 'fossil get --help' for more information"
            ]
          end

          @@server = args[0]
        end
      end

      cfg = Commands::Config.read_config
      http = Http.new cfg
      backup = Http.new(cfg).create_backup @@server, @@name, @@locked, @@ignored

      Log.info [
        "created new archive",
        "uuid: #{backup.uuid}",
        "name: #{backup.name}",
        "size: #{backup.bytes}",
        "locked: #{backup.is_locked}",
        "successful: #{backup.is_successful}"
      ]
      exit
    end
  end
end
