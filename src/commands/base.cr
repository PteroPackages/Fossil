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

    def help_template : String
      orange = Colorize::ColorRGB.new(225, 105, 20)

      String.build do |io|
        if description = @description
          io << description << "\n\n"
        end

        io << "Usage".colorize(orange) << '\n'
        @usage.each do |use|
          io << "> " << use << '\n'
        end
        io << '\n'

        unless @children.empty?
          io << "Commands".colorize(orange) << '\n'
          max_size = 4 + @children.keys.max_of &.size

          @children.each do |name, command|
            io << "> " << name
            if summary = command.summary
              io << " " * (max_size - name.size)
              io << summary
            end
            io << '\n'
          end

          io << '\n'
        end

        unless @arguments.empty?
          io << "Arguments".colorize(orange) << '\n'
          max_size = 4 + @arguments.keys.max_of &.size

          @arguments.each do |name, argument|
            io << "> " << name
            if description = argument.description
              io << " " * (max_size - name.size)
              io << description
            end
            io << '\n'
          end

          io << '\n'
        end

        io << "Options".colorize(orange) << '\n'
        max_size = 4 + @options.each.max_of { |name, opt| name.size + (opt.short ? 2 : 0) }

        @options.each do |name, option|
          io << "> "
          if short = option.short
            io << '-' << short << ", "
          end
          io << "--" << name

          if description = option.description
            name_size = name.size + (option.short ? 4 : 0)
            io << " " * (max_size - name_size)
            io << description
          end
          io << '\n'
        end
      end
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

    protected def system_exit : NoReturn
      raise SystemExit.new
    end

    def on_error(ex : Exception)
      case ex
      when SystemExit
        raise ex
      when Cling::CommandError
        error ex
        error "See 'fossil --help' for more information"
      when Fossil::Config::Error
        error "Error while loading configuration:"
        error ex
      else
        error "Unexpected exception:"
        error ex
        error "Please report this on the Fossil GitHub issues:"
        error "https://github.com/PteroPackages/Fossil/issues"
      end
    end

    def on_missing_arguments(args : Array(String))
      error %(Missing required argument#{"s" if args.size > 1}: #{args.join ","})
      system_exit
    end

    def on_unknown_arguments(args : Array(String))
      format = args.first(5).join ", "
      if args.size > 5
        format += " (and #{args.size - 5} more)"
      end

      error "Unexpected argument#{"s" if args.size > 1}: #{format}"
      system_exit
    end

    def on_unknown_options(options : Array(String))
      format = options.first(5).join ", "
      if options.size > 5
        format += " (and #{options.size - 5} more)"
      end

      error "Unexpected option#{"s" if options.size > 1}: #{format}"
      system_exit
    end
  end
end
