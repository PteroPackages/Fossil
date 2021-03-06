require "option_parser"

module Fossil::Commands
  # Handles deleting backups on servers.
  class Delete
    @@server = ""
    @@id = ""

    # :nodoc:
    def self.send_help
      puts <<-HELP
      Handles deleting backups on servers.

      Usage:
          fossil delete <server> [--id <id>] [-h|--help]

      Arguments:
          server      the identifier of the server

      Options:
          --id <id>   the identifier or uuid of the backup
          -h, --help  send help information
      HELP

      exit
    end

    # :nodoc:
    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("--id <id>", "the identifier or uuid of the backup") { |v| @@id = v }
        parser.on("-h", "--help", "send help information") { send_help }

        parser.missing_option { |op| Log.fatal "missing option #{op} <...>" }
        parser.unknown_args do |args, _|
          case args.size
          when 0
            Log.fatal [
              "missing server identifier to download from",
              "run 'fossil delete --help' for more information"
            ]
          when 1
            @@server = args[0]
          else
            Log.fatal [
              "more than one identifier target specified; only put one",
              "run 'fossil get --help' for more information"
            ]
          end
        end
      end

      cfg = Commands::Config.read_config
      http = Http.new cfg
      backups = http.get_backups @@server
      if backups.nil?
        Log.fatal [
          "the requested server is currently unavailable",
          "check that it is not installing or transferring before retrying"
        ]
      end

      unless @@id == ""
        backup = backups.find { |b| b.uuid.includes? @@id }
        if backup.nil?
          Log.fatal [
            "a backup with this identifier or uuid was not found:",
            @@id,
            "run 'fossil list --own' to see current server backups"
          ]
        end

        http.delete_backup @@server, backup.uuid
        Log.info ["deleted backup:", backup.uuid]
        exit
      end

      deleted = [] of String
      backups.each do |backup|
        begin
          http.delete_backup @@server, backup.uuid
          deleted << backup.uuid
        rescue
          Log.warn ["failed to delete backup:", backup.uuid]
        end
      end

      if deleted.size == 0
        Log.info "no backups were deleted"
        exit
      else
        Log.info ["deleted the following backups:"] + deleted
        exit
      end
      exit 1
    end
  end
end
