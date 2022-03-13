module Fossil::Commands
  class Config
    def initialize(args, opts)
      send_help unless args[0]?

      case args[0]
      when "show"
        show_config
      when "set"
        # TODO
        exit
      when "init"
        init_config
      when "reset"
        # TODO
        exit
      else
        Logger.error "unknown subcommand '#{args[0]}'", true
      end

      exit 0
    end

    def send_help
      STDOUT << <<-HELP
      Commands for managing the Fossil config

      Usage:
          fossil config [options] <command>

      SubCommands:
          show    shows the current config
          init    initializes a new config
          set     sets a key in the config
          reset   resets the config setup

      Options:
          -f, --force don't prompt the user to continue
      HELP

      exit 0
    end

    def self.get_config : Models::Config
      unless path = ENV["FOSSIL_PATH"]?
        Logger.error "not set", true
      end

      unless File.exists? path.not_nil!
        Logger.error "not exist", true
      end

      file = File.read Path[path.not_nil!].join "config.yml"
      Models::Config.from_yaml file
    end

    def show_config
      cfg = self.class.get_config

      STDOUT << <<-CFG
      domain:  #{cfg.domain}
      api key: #{cfg.auth}
      archive dir: #{cfg.archive}
      default file format: #{cfg.formats["file"]}
      default export format: #{cfg.formats["export"]}
      CFG
    end

    def init_config
      unless File.exists? "#{__DIR__}/../config.tmpl.ecr"
        Logger.error [
          "missing template confir ecr file to continue",
          "please reinstall Fossil to fix this, or manually add the file"
        ], true
      end

      basedir : String
      {% if flag?(:win32) %}
      basedir = "C:\\Program Files\\Fossil"
      {% else %}
      basedir = "/usr/etc/fossil"
      {% end %}

      Dir.mkdir basedir
      tmpl = ECR.render "#{__DIR__}/../config.tmpl.ecr"
      path = Path.new basedir, "config.yml"
      File.write path, tmpl
    end
  end
end
