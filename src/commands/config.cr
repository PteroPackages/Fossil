require "option_parser"

module Fossil::Commands
  struct Conf
    property domain : String
    property key    : String

    def initialize(@domain = "", @key = "")
    end
  end

  # Manages the Fossil configuration file.
  class Config
    PATH = "/etc/fossil.conf"

    @@force = false

    # :nodoc:
    def self.send_help
      puts <<-HELP
      Manages the Fossil configuration file.

      Usage:
          fossil config [-d|--domain <url>] [-k|--key <key>]
                        [-f|--force] [-i|--init] [-h|--help]

      Options:
          -i, --init      initialize a new config file
          -f, --force     force overwrite the existing config
          --domain <url>  set the domain for pterodactyl
          --key <key>     set the account api key
          -h, --help      send help information
      HELP

      exit
    end

    # :nodoc:
    def self.run(args)
      OptionParser.parse(args) do |parser|
        parser.on("-i", "--init", "initialize a new config file") { init }
        parser.on("-f", "--force", "force overwrite the config") { @@force = true }
        parser.on("--domain <url>", "set the domain for pterodactyl") { |v| set_domain v }
        parser.on("--key <key>", "set the account api key") { |v| set_key v }
        parser.on("-h", "--help", "send help information") { send_help }

        parser.missing_option { |op| Log.fatal "missing option #{op} <...>" }
      end

      cfg = read_config
      cfg.domain = "<not set>" if cfg.domain.empty?
      cfg.key = "<not set>" if cfg.key.empty?
      puts "domain: #{cfg.domain}\nkey:    #{cfg.key}"
      exit
    end

    # Initializes a new configuration file at the default `PATH`.
    # Unfortunately, this is prone to error since the binary/executable will likely not
    # have the necessary permissions to read and write at this path, so stricter system
    # checks will need to be added for better safety.
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

    # Reads the config file and returns the domain and api key.
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

    # Sets the domain for Fossil to use
    #
    # TODO: add validation
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

    # Sets the api key for Fossil to use
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
