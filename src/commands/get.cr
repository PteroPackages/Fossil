require "option_parser"

module Fossil::Commands
  # Manages backup download processes.
  class Get
    PATH = "/var/fossil/archives"

    @@server = ""
    @@id = ""
    @@download = true

    # :nodoc:
    def self.send_help
      puts <<-HELP
      Manages backup download processes.

      Usage:
          fossil get <server> [--id <id>] [-u|--url-only] [-h|--help]

      Arguments:
          server          the identifier of the server

      Options:
          --id <id>       the identifier or uuid of the backup
          -u, --url-only  only return the download url(s)
          -h, --help      send help information
      HELP

      exit
    end

    # :nodoc:
    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("--id <id>", "the identifier or uuid of the backup") { |v| @@id = v }
        parser.on("-u", "--url-only", "only return the download url(s)") { @@download = false }
        parser.on("-h", "--help", "send help information") { send_help }

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

        url = http.get_download_url @@server, backup.uuid
        unless @@download
          puts url
          exit
        end

        dl = http.get_download url
        if path = write dl
          Log.info ["saved archive at:", path]
          exit
        end

        exit 1
      end

      urls = {} of String => String
      backups.each do |backup|
        url = http.get_download_url @@server, backup.uuid
        if url.nil?
          Log.warn ["failed to get url for backup:", backup.uuid]
          next
        end

        urls[backup.uuid] = url
      end

      if urls.size == 0
        Log.fatal "no backup urls were returned"
      end

      unless @@download
        urls.each { |i, u| puts "#{i}:\n#{u}\n\n" }
        exit
      end

      saved = [] of String
      urls.each do |_, url|
        dl = http.get_download url
        if path = write dl
          saved << path
        end
      end

      if saved.size == 0
        Log.info "no backups were downloaded"
        exit
      else
        Log.info ["saved downloads at these paths:"] + saved
        exit
      end
    end

    # Writes the buffered data to the archive path.
    # TODO: maybe add a limit to this?
    private def self.write(dl)
      path = Path[PATH].join Time.utc.to_s "%F"
      Dir.mkdir_p(path) unless Dir.exists? path

      path /= dl.name
      if File.exists? path
        Log.warn [
          "archive already exists:",
          path.to_s,
          "attempting to overwrite"
        ]
      end

      begin
        File.write path, dl.data

        path.to_s
      rescue
        Log.warn ["failed to write to path:", path.to_s]

        nil
      end
    end
  end
end
