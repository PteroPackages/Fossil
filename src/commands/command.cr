module Fossil::Commands
  abstract class Command
    property config : Config

    def initialize
      @config = Config.fetch
    end

    def debug(message)
      Logger.debug message
    end

    abstract def run
  end
end
