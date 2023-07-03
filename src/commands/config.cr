module Fossil::Commands
  class Config < Base
    def setup : Nil
      @name = "config"
      @summary = "fossil config management"
      @description = "Shows the current config or modifies fields with the given flags."

      add_usage "fossil config [--url <url>] [--key <key>] [options]"

      add_option "url", description: "the url to set", type: :single
      add_option "key", description: "the key to set", type: :single
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      Fossil::Config.load_unchecked

      if options.empty?
        info Fossil::Config.url
        info Fossil::Config.key
        return
      end

      if url = options.get?("url")
        Fossil::Config.url = url.as_s
      end

      if key = options.get?("key")
        Fossil::Config.key = key.as_s
      end

      Fossil::Config.save
    end
  end
end
