require "option_parser"

module Fossil::Commands
  # Gets the status and specific information about a backup.
  class Status
    @@server = ""
    @@id = ""
    @@op = :none

    def self.send_help
      puts <<-HELP
      Gets the status and specific information about a backup.

      Usage:
          fossil status <server> [--id <id>] [-f|--first]
                                  [-l|--last] [-h|--help]

      Arguments:
          server      the identifier of the server

      Options:
          --id <id>   the identifier or uuid of the backup
          -f, --first get the first backup's status
          -l, --last  get the last backup's status
          -h, --help  send help information
      HELP

      exit
    end

    # :nodoc:
    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("-h", "--help", "send help information") { send_help }
        parser.on("-f", "--first", "get the first backup's status") { @@op = :first }
        parser.on("-l", "--last", "get the last backup's status") { @@op = :last }

        parser.missing_option { |op| Log.fatal "missing option #{op} <...>" }
        parser.unknown_args do |args, _|
          case args.size
          when 0
            Log.fatal [
              "missing server identifier to download from",
              "run 'fossil get --help' for more information"
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

      if @@id == "" && @@op == :none
        Log.fatal [
          "a backup identifier/uuid or operator must be specified",
          "run 'fossil restore --help' for more information"
        ]
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

      if backups.size == 0
        Log.error "there are no backups on this server to restore"
        Log.info "create one using 'fossil create'"
        exit 1
      end

      backup = uninitialized Models::Backup
      unless @@id == ""
        b = backups.find { |b| b.uuid.includes? @@id }
        if b.nil?
          Log.fatal [
            "a backup with this identifier or uuid was not found:",
            @@id,
            "run 'fossil list --own' to see current server backups"
          ]
        end

        backup = b
      else
        case @@op
        when :first   then backup = backups.first
        when :last    then backup = backups.last
        end
      end

      Log.info [
        "name: #{backup.name}",
        "uuid: #{backup.uuid}",
        "size: #{backup.bytes}",
        "checksum: #{backup.checksum}",
        "locked: #{backup.is_locked}",
        "successful: #{backup.is_successful}",
        "created at: #{backup.created_at}",
        "completed at: #{backup.completed_at}"
      ]
      exit
    end
  end
end
