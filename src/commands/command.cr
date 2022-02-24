module Fossil::Commands
  abstract class Command
    def initialize
    end

    def self.run(*args)
      new.run *args
    end

    def debug(message)
      Logger.debug message
    end
  end
end
