module Fossil::Commands
  abstract class BaseCommand < CLI::Command
    @inherit_options = true

    def initialize
      super

      add_option "no-color", desc: "disable ansi color codes"
      add_option "trace", desc: "log error stack traces"
      add_option 'h', "help", desc: "get help information"
    end

    def pre_run(args, options)
      if options.has? "help"
        stdout.puts help_template

        false
      else
        true
      end
    end

    def on_error(ex : Exception)
      return if ex.is_a? SystemExit
      return ex.print_log if ex.is_a? Error

      Error.new(:uncaught, ex).print_log
    end

    def format_name : String
      "fossil" + (self.name == "_main" ? "" : " " + self.name)
    end

    def on_missing_arguments(args)
      Log.fatal [
        %(Missing required argument#{"s" if args.size > 1}: #{args.join ","}),
        "See '$B#{format_name} --help$R' for more information",
      ]
    end

    def on_unknown_arguments(args)
      format = args.first(5).join ", "
      extra = args.size > 5 ? "(and #{args.size - 5} more)" : ""

      Log.fatal [
        "Unknown arguments for #{format_name} command: #{format} #{extra}",
        "See '$B#{format_name} --help$R' for more information",
      ]
    end

    def on_unknown_options(options)
      format = options.first(5).join ", "
      extra = options.size > 5 ? "(and #{options.size - 5} more)" : ""

      Log.fatal [
        "Unknown options for #{format_name} command: #{format} #{extra}",
        "See '$B#{format_name} --help$R' for more information",
      ]
    end
  end
end
