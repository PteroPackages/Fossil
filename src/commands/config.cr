module Fossil::Commands
  class ConfigCommand < CLI::Command
    include Base

    def setup : Nil
      @name = "config"
      @description = "Shows the current config or modifies fields with the given flags."
      @usage << "config --set [--url <url>] [--key <key>]"
      @usage << "config --reset"

      add_option "set", desc: "sets the command into write mode to update the config"
      add_option "url", desc: "shows the current url, or updates it if in write mode", kind: :string, default: ""
      add_option "key", desc: "shows the current key, or updates it if in write mode", kind: :string, default: ""
      add_option "reset", short: "r", desc: "resets the config file"
    end

    def execute(args, options) : Nil
      if options.has? "reset"
        Config.new("https://pterodactyl.domain", "ptlc_your_api_key").save
        raise SystemExit.new
      end

      cfg = Config.fetch
      url = options.get! "url"
      key = options.get! "key"

      if options.has? "set"
        Log.fatal [
          "No panel URL or API key specified",
          "See 'fossil config --help' for more information",
        ] if url.empty? && key.empty?

        cfg.url = url unless url.empty?
        cfg.key = key unless key.empty?
        cfg.save
      else
        Log.write [cfg.url, cfg.key]
      end
    rescue File::AccessDeniedError
      raise Error.new :config_write_denied
    rescue File::NotFoundError
      raise Error.new :config_not_found
    end
  end
end
