require "option_parser"

module Fossil::Commands
  class List
    PATH = "/var/fossil/archives"

    @@access = ""

    def self.send_help
      puts <<-HELP
      Usage:
          fossil list [options]

      Options:
          -a, --all
          -o, --own
          -h, --help
      HELP

      exit
    end

    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("-h", "--help", "sends help information") { send_help }
        parser.on("-a", "--all", "get all server backups") { @@access = "admin-all" }
        parser.on("-o", "--own", "get backups of servers you own") { @@access = "owner" }
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
        Log.info "you have 0 backups across all your servers!"
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
