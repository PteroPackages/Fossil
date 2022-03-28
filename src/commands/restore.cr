require "compress/gzip"
require "option_parser"

module Fossil::Commands
  class Restore
    property config  : Models::Config
    property verbose : Bool
    property dir     : String

    def send_help
      STDOUT << <<-HELP
      Usage:
          fossil restore <file_pattern>

          file_pattern must be a file path or directory pattern
          example: "2022-02-02/*"

      HELP

      exit
    end

    def initialize(args, options)
      send_help unless args[0]?

      @verbose = false
      @dir = ""

      OptionParser.parse(args) do |parser|
        parser.on("--verbose", "use verbose logging") { @verbose = true }
        parser.on("-o <dir>", "--output <dir>", "the output directory") { |d| @dir = d }
      end

      @config = Config.get_config
      run args
    end

    def run(args)
      files = if args[0].includes? '*'
        Dir.glob Path[@config.archive].join args[0]
      else
        [File.expand_path args[0], @config.archive]
      end
      puts files
      files = files.select! { |f| f.ends_with? ".gz" }

      Logger.error("no files found", true) if files.size == 0
      Logger.info "#{files.size} file(s) found"

      cache = Path[@config.archive].join "cache"
      Dir.mkdir_p(cache) unless Dir.exists? cache
      restored = 0

      files.each_with_index do |file, index|
        Logger.info "restoring archive (%d/%d)" % [index + 1, files.size]

        begin
          data = Compress::Gzip::Reader.open(file) { |gz| gz.gets_to_end }
          fp = Path[cache].join Path.new(file).basename[..-3]
          File.write fp, data
          restored += 1
        rescue
          Logger.error "failed to restore archive; skipping"
        end
      end

      Logger.success [
        "restored #{restored} archive(s) at:",
        cache.to_s
      ]
    end
  end
end
