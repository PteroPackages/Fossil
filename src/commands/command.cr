module Fossil::Commands
  abstract class Command
    getter config : Config

    def initialize
      @config = Config.fetch
    end

    def self.run(*args)
      new.run *args
    end

    def debug(message)
      Logger.debug message
    end
  end
end
