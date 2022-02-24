module Fossil::Commands
  class ConfigSetup < Command
    def run(args : Array(String), opts : CmdOptions)
      send_help! unless args[0]?

      case args[0]
      when "show"
        show_config
      when "set"
        # TODO
        exit
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
          set
          reset

      Options:
          -f, --force
          -h, --help
      HELP

      exit 0
    end

    def show_config
      puts <<-CFG
      domain:  #{@config.domain}
      api key: #{@config.auth}

      cache_path: #{@config.cache_path}
      export fmt: #{@config.format}
      CFG
    end
  end
end
