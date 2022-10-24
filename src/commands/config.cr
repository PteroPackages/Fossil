module Fossil::Commands
  class SetConfigCommand < BaseCommand
    def setup : Nil
      @name = "set"
      @description = "Sets an option in the config to a value."
      add_usage "config set <option> <value>"

      add_argument "option", desc: "the config option to change", required: true
      add_argument "value", desc: "the value to set", required: true
    end

    def on_missing_arguments(args)
      Log.fatal [
        %(Missing required argument#{"s" if args.size == 2}: #{args.join ", "}),
        "See '$Bfossil config set --help$R' for more information",
      ]
    end

    def run(args, options) : Nil
      op = args.get!("option").as_s

      unless op == "url" || op == "key"
        Log.fatal ["Invalid config option '#{op}'", "Valid options: url, key"]
      end

      cfg = Config.fetch
      value = args.get!("value").as_s

      case args.get! "option"
      when "url" then cfg.url = value
      when "key" then cfg.key = value
      end

      cfg.save
    rescue File::AccessDeniedError
      raise Error.new :config_write_denied
    rescue File::NotFoundError
      raise Error.new :config_not_found
    end
  end

  class ResetConfigCommand < BaseCommand
    def setup : Nil
      @name = "reset"
      @desciption = "Resets the config to an example template."
      add_usage "config reset"
    end

    def run(args, options) : Nil
      Config.write_template
    rescue File::AccessDeniedError
      raise Error.new :config_write_denied
    end
  end

  class ConfigCommand < BaseCommand
    def setup : Nil
      @name = "config"
      @description = "Shows the current config or modifies fields with the given flags."
      add_usage "config set <option> <value>"
      add_usage "config reset"

      add_command SetConfigCommand.new
      add_command ResetConfigCommand.new
    end

    def run(args, options) : Nil
      cfg = Config.fetch
      Log.write [cfg.url, cfg.key]
    rescue File::NotFoundError
      raise Error.new :config_not_found
    end
  end
end
