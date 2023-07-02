module Fossil::Commands
  abstract class Base < Cling::Command
    def initialize
      super

      @debug = false
      @inherit_options = true
      add_option "debug", description: "print debug information"
      add_option "no-color", description: "disable ansi color codes"
      add_option 'h', "help", description: "get help information"
    end

    def pre_run(arguments : Cling::Arguments, options : Cling::Options) : Bool
      @debug = true if options.has? "debug"
      Colorize.enabled = false if options.has? "no-color"

      if options.has? "help"
        stdout.puts help_template

        false
      else
        true
      end
    end

    protected def debug(data : _) : Nil
      return unless @debug
      stdout << "Debug: " << data << '\n'
    end

    protected def info(data : _) : Nil
      stdout.puts data
    end

    protected def warn(data : _) : Nil
      stdout << "Warning: ".colorize.yellow << data << '\n'
    end

    protected def error(data : _) : Nil
      stderr << "Error: ".colorize.red << data << '\n'
    end

    def on_error(ex : Exception)
      raise ex if ex.is_a? SystemExit

      if ex.is_a? Cling::CommandError
        error ex.to_s
        error "See 'fossil --help' for more information"
        return
      end

      error "Unexpected exception:"
      error ex
      error "Please report this on the Fossil GitHub issues:"
      error "https://github.com/PteroPackages/Fossil/issues"
    end

    def on_missing_arguments(args : Array(String))
      error %(Missing required argument#{"s" if args.size > 1}: #{args.join ","})
    end

    def on_unknown_arguments(args : Array(String))
      format = args.first(5).join ", "
      if args.size > 5
        format += " (and #{args.size - 5} more)"
      end

      error "Unexpected argument#{"s" if args.size > 1}: #{format}"
    end

    def on_unknown_options(options : Array(String))
      format = options.first(5).join ", "
      if options.size > 5
        format += " (and #{options.size - 5} more)"
      end

      error "Unexpected option#{"s" if options.size > 1}: #{format}"
    end
  end
end
