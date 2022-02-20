module Fossil
  class FossilError
    property stack : Array(String)

    def initialize
      @stack = [] of String
    end

    def add_to_stack(message) : Nil
      @stack << message
    end

    def format_file
      # TODO
    end

    def format_log : String?
      return nil if @stack.size == 0
    end
  end
end
