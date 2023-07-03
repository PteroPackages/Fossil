# Modified implementation of https://github.com/askn/progress

module Fossil
  class Progress
    WIDTH = 64

    @current : Float64
    @total : Float64

    def initialize(@total)
      @current = 0.0
      print "\33[?25l"
    end

    def tick : Nil
      old_percent = percent
      @current += 1
      @current = 0.0 if @current < 0
      @current = @total if @current > @total
      new_percent = percent
      print(new_percent) if new_percent != old_percent
    end

    # Might not need this yet
    # def pause(& : ->) : Nil
    #   print "\33[2K\r"
    #   yield
    #   print percent
    # end

    def done : Nil
      print "\33[?25h\33[2K\r"
    end

    private def percent : String
      sprintf "%.2f", @current / (@total / 100.0)
    end

    private def print(percent : String) : Nil
      STDERR.flush
      STDERR.print "|#{"\u2593" * position}#{"\u2591" * (WIDTH - position)}| #{percent}%\r"
      STDERR.flush
    end

    private def position : Int32
      ((@current * WIDTH) / @total).to_i
    end
  end
end
