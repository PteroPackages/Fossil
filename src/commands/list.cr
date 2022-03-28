require "option_parser"

module Fossil::Commands
  class List
    property config   : Models::Config
    property archives : Bool
    property exports  : Bool
    property order    : Symbol
    property format   : String

    def send_help
      STDOUT.puts <<-HELP
      Usage:
          fossil list [options] <flags>

      Flags:
          -a, --archives
          -e, --exports

      Options:
          --order <asc|desc>
          --format <str>
              %i - file index
              %n - file name
              %e - file extension
              %s - file size
      HELP

      exit
    end

    def initialize(args, options)
      @archives = false
      @exports = false
      @order = :asc
      @format = "%i - %n"

      OptionParser.parse(args) do |parser|
        parser.on("-a", "--archives", "lists stored archives") { @archives = true }
        parser.on("-e", "--exports", "lists zipped export archives") { @exports = true }
        parser.on("-o <asc|desc>", "--order <asc|desc>", "sets the order type") do |o|
          case o.downcase
          when "asc"  then @order = :asc
          when "desc" then @order = :desc
          else
            Logger.error "invalid order type '#{o}'", true
          end
        end
        parser.on("--format <str>", "sets the output format") { |f| @format = f }
      end

      @config = Config.get_config
      run
    end

    def run
      Logger.error("archives or exports must be specified", true) unless @archives || @exports
      stack = [] of Array(String)
      stack += get_archives(@config.archive_dir) if @archives
      stack += get_exports(@config.export_dir) if @exports

      return STDOUT.puts if stack.size == 0
      STDOUT.puts stack.map { |s| format_line s[0], s[1] }.join '\n'
    end

    def get_archives(dir, stack = 0) : Array(Array(String))
      return [] of Array(String) if stack == 5
      dir += File::SEPARATOR + "*"
      files = [] of Array(String)

      Dir.glob(dir).each_with_index do |path, index|
        if File.directory? path
          files += get_archives(path, stack + 1)
        else
          if path =~ /\.(?:json|ya?ml|xml)/i
            files << ["#{stack}:#{index}", path]
          end
        end
      end
      files
    end

    def get_exports(dir, stack = 0) : Array(Array(String))
      return [] of Array(String) if stack == 5
      dir += File::SEPARATOR + "*"
      files = [] of Array(String)

      Dir.glob(dir).each_with_index do |path, index|
        if File.directory? path
          files + get_exports(path, stack + 1)
        else
          if path.ends_with? ".gz"
            files << ["#{stack}:#{index}", path]
          end
        end
      end
      files
    end

    def format_line(index, file)
      line = @format
      path = Path.new file
      {
        "%i" => index,
        "%n" => path.basename,
        "%e" => path.extension,
        "%s" => File.size(file)
      }.each { |c, v| line = line.gsub c, v }
      line
    end
  end
end
