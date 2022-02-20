module Fossil
  struct ErrorEntry
    property message : Array(String)
    property trace   : Array(String)
    property notice  : String?

    def initialize(@message, *, @trace = [] of String, @notice = nil)
    end

    def initialize(message : String)
      new [message]
    end
  end

  class Log
    property err_stack  : Array(ErrorEntry)
    property use_colour : Bool

    def initialize(colour : Bool)
      @err_stack = [] of ErrorEntry
      @use_colour = self._no_colour? || colour
    end

    def _no_colour? : Bool
      return true unless ENV["NO_COLOR"]?
      ENV["NO_COLOR"] == 0
    end

    def write(message)
      puts message
    end
  end
end
