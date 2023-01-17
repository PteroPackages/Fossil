module Fossil::Commands
  abstract class BaseCommand < CLI::Command
    @inherit_options = true

    def initialize
      super

      add_option "no-color", description: "disable ansi color codes"
      add_option "trace", description: "log error stack traces"
      add_option 'h', "help", description: "get help information"
    end

    def pre_run(arguments, options)
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

      if ex.is_a? CLI::CommandError && (message = ex.message) && message.includes? "not found"
        Log.fatal [
          "Unknown command #{message.split(' ')[1]}",
          "See '$Bfossil --help$R' for more information",
        ]
      end

      Error.new(:uncaught, ex).print_log
    end

    def format_name : String
      "fossil" + (self.name == "app" ? "" : " " + self.name)
    end

    def on_missing_arguments(arguments)
      Log.fatal [
        %(Missing required argument#{"s" if arguments.size > 1}: #{arguments.join ","}),
        "See '$B#{format_name} --help$R' for more information",
      ]
    end

    def on_unknown_arguments(arguments)
      format = arguments.first(5).join ", "
      extra = arguments.size > 5 ? "(and #{arguments.size - 5} more)" : ""

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
