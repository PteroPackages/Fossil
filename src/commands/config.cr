module Fossil::Commands
  class Config
    def initialize(args, opts)
      send_help unless args[0]?

      case args[0]
      when "show"
        show_config
      when "set"
        set_config args
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
      domain:      #{cfg.domain}
      api key:     #{cfg.auth}
      archive dir: #{cfg.archive}
      default file format:   #{cfg.formats["file"]}
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

    def set_config(args)
      key, value = args[1]?, args[2]?
      unless key && value
        STDOUT << <<-HELP
        Usage:
            fossil config set <key> <value>

        Options:
            domain          the domain url of the panel
            auth            the application api key
            archive         the path to the archive directory
            formats.file    the file format to save archives
            formats.export  the file format to export archives

        HELP

        exit 0
      end

      unless ["domain", "auth", "archive", "formats.file", "formats.export"].includes? key.downcase
        Logger.error "invalid config option '#{key}'", true
      end

      case key.downcase
      when "archive"
        unless Dir.exists? value
          Logger.error "invalid archive directory", true
        end

      when "formats.file"
        unless ["json", "yaml", "yml"].includes? value.downcase
          Logger.error "invalid file format '#{value}'", true
        end

      when "formats.export"
        unless value.downcase == "zip"
          Logger.error "only zip is currently supported for exports", true
        end
      end

      config = self.class.get_config
      config[key] = value
      path = Path[config.archive].join "config.yml"
      File.write path, config.to_yaml

      Logger.success "updated the config"
    end
  end
end
