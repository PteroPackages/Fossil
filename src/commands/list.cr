require "option_parser"

module Fossil::Commands
  # Sends overview details about server backups.
  class List
    PATH = "/var/fossil/archives"

    @@access = ""

    # :nodoc:
    def self.send_help
      puts <<-HELP
      Sends overview details about server backups.

      Usage:
          fossil list [-a|--all] [-o|--own] [-h|--help]

      Options:
          -a, --all   list all servers the account has access to
          -o, --own   list all servers the account owns
          -h, --help  send help information
      HELP

      exit
    end

    # :nodoc:
    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("-a", "--all", "get all server backups") { @@access = "admin-all" }
        parser.on("-o", "--own", "get backups of servers you own") { @@access = "owner" }
        parser.on("-h", "--help", "send help information") { send_help }
      end

      cfg = Commands::Config.read_config
      http = Http.new cfg
      servers = http.get_servers(@@access).map { |s| s.identifier }
      cache = {} of String => Array(Models::Backup)

      servers.each do |id|
        Log.info "getting backups for: #{id}"
        if backup = http.get_backups id
          cache[id] = backup
        else
          Log.warn "failed to get backups for: #{id}; skipping"
        end
      end

      if cache.size == 0
        Log.info "you have 0 backups across all your servers"
        exit
      end

      cache.each do |id, backups|
        puts "identifier: #{id}\n--------------------"
        if backups.size == 0
          puts "no backups\n\n"
        else
          backups.each_with_index do |b, i|
            puts "##{i+1}\nuuid: #{b.uuid}\nsize: #{b.bytes}\n\n"
          end
        end
      end

      exit
    end
  end
end
