require "option_parser"

module Fossil::Commands
  class Restore
    @@server = ""
    @@id = ""
    @@op = :none

    def self.send_help
      puts <<-HELP
      Usage:
          fossil restore [options] <server>

      Options:
          --id <id>
          -f, --first
          -l, --last
          -r, --random
      HELP

      exit
    end

    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("-h", "--help", "sends help information") { send_help }
        parser.on("--id <id>", "the identifier or uuid of the backup") { |v| @@id = v }
        parser.on("-f", "--first", "restores the first backup") { @@op = :first }
        parser.on("-l", "--last", "restores the last backup") { @@op = :last }
        parser.on("-r", "--random", "restores a random backup") { @@op = :random }

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
        exit
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
        when :first   then backup = backups[0]
        when :last    then backup = backups.last
        when :random  then backup = backups[rand(backups.size)]
        end
      end

      http.restore_backup @@server, backup.uuid
      Log.info ["restored backup:", backup.uuid]
      exit
    end
  end
end
