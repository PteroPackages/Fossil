module Fossil::Commands
  class ConfigSetup
    def initialize(args, opts)
      send_help! unless args[0]?

      case args[0]
      when "show"
        show_config
      when "set"
        # TODO
        exit
      when "init"
        init_config opts.debug
      when "reset"
        # TODO
        exit
      else
        Logger.error "unknown subcommand '#{args[0]}'", true
      end

      exit 0
    end

    def send_help!
      puts <<-HELP
      Commands for managing the Fossil config

      Usage:
          fossil config [options] <command>

      SubCommands:
          show
          init
          set
          reset

      Options:
          -f, --force
          -h, --help
      HELP

      exit 0
    end

    def show_config
      cfg = Config.fetch

      puts <<-CFG
      domain:  #{cfg.domain}
      api key: #{cfg.auth}
      archive dir: #{cfg.archive_dir}
      default file format: #{cfg.file_format}
      default export format: #{cfg.export_format}
      CFG
    end

    def init_config(debug)
      Logger.info "attempting to create config"
      Config.init debug
      Logger.info "created new fossil config"
    end
  end
end
