module Fossil::Commands
  class SetConfigCommand < BaseCommand
    def setup : Nil
      @name = "set"

      add_argument "option", desc: "the config option to change", required: true
      add_argument "value", desc: "the value to set", required: true
    end

    def pre_run(args, options)
      op = args.get("option").try(&.as_s) || ""

      unless op == "url" || op == "key"
        Log.fatal ["invalid config option '#{op}'", "valid options: url, key"]
      end
    end

    def run(args, options) : Nil
      cfg = Config.fetch

      case args.get("option").try(&.as_s) || ""
      when "url" then cfg.url = args.get("value").try(&.as_s) || ""
      when "key" then cfg.key = args.get("value").try(&.as_s) || ""
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
      add_usage "config set [--url <url>] [--key <key>]"
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
