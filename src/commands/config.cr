require "option_parser"

module Fossil::Commands
  struct Conf
    property domain : String
    property key    : String

    def initialize(@domain = "", @key = "")
    end
  end

  class Config
    PATH = "/etc/fossil.conf"

    @@force = false

    def self.send_help
      puts <<-HELP
      Usage:
          fossil config [options]

      Options:
          -i, --init
          -f, --force
          --domain <url>
          --key <key>
          -h, --help
      HELP

      exit
    end

    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("-h", "--help", "sends help information") { send_help }
        parser.on("-f", "--force", "force overwrite the config") { @@force = true }
        parser.on("-i", "--init", "initializes a new config file") { init }
        parser.on("--domain <url>", "sets the domain for pterodactyl") { |v| set_domain v }
        parser.on("--key <key>", "sets the account api key") { |v| set_key v }

        parser.missing_option { |op| Log.fatal "missing option #{op} <...>" }
      end

      cfg = read_config
      cfg.domain = "<not set>" if cfg.domain.empty?
      cfg.key = "<not set>" if cfg.key.empty?
      puts "domain: #{cfg.domain}\nkey: #{cfg.key}"
      exit
    end

    def self.init
      if File.exists? PATH
        unless @@force
          Log.error [
            "config file already exists",
            "path: " + PATH
          ]
          Log.info "use the '--force' option to force overwrite"
          exit 1
        end
      end

      begin
        File.write PATH, "domain=\nkey="
        exit
      rescue File::AccessDeniedError
        Log.error "missing permissions to write to config path"
        Log.info [
          " possible solutions:",
          "  sudo chmod 775 /bin/fossil",
          "  touch #{PATH} (if not exists)",
          "  chmod 666 #{PATH}"
        ]
        exit
      rescue ex
        Log.error "failed to write to config"
        Log.fatal ex
      end
    end

    def self.read_config
      unless File.exists? PATH
        Log.fatal [
          "config file does not exist (path: #{PATH})",
          "run 'fossil config init' to create one"
        ]
      end

      begin
        data = File.read PATH
      rescue ex
        Log.fatal ex
      end

      cfg = Conf.new
      cfg.domain = data.lines.find("domain=") { |line| line.starts_with? "domain=" }[7..]
      cfg.key = data.lines.find("key=") { |line| line.starts_with? "key=" }[4..]

      cfg
    end

    def self.set_domain(url)
      cfg = read_config
      cfg.domain = url

      begin
        File.write PATH, "domain=#{cfg.domain}\nkey=#{cfg.key}"
        exit
      rescue ex
        Log.fatal ex
      end
    end

    def self.set_key(key)
      cfg = read_config
      cfg.key = key

      begin
        File.write PATH, "domain=#{cfg.domain}\nkey=#{cfg.key}"
        exit
      rescue ex
        Log.fatal ex
      end
    end
  end
end
