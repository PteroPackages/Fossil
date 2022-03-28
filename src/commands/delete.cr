require "option_parser"

module Fossil::Commands
  class Delete
    property config    : Models::Config
    property verbose   : Bool
    property recursive : Bool
    property force     : Bool

    def send_help
      STDOUT.puts <<-HELP
      Usage:
          fossil delete [options] <file_pattern>

          file_pattern must be a file path or directory pattern
          example: "2022-02-02/*"

      Options:
          --verbose       use verbose logging
          -r, --recursive recursively search for the file
          -f, --force     don't prompt the user to continue
      HELP

      exit
    end

    def initialize(args, opts)
      send_help unless args[0]?

      @verbose = true
      @recursive = false
      @force = false

      OptionParser.parse(args) do |parser|
        parser.on("--verbose", "use verbose logging") { @verbose = true }
        parser.on("-r", "--recursive", "recursively search for the file") { @recursive = true }
        parser.on("-f", "--force", "don't prompt the user to continue") { @force = true }

        parser.unknown_args do |unknown, _|
          if unknown.any? &.starts_with? "-"
            Logger.error %(unknown option#{unknown.size > 1 ? "s" : ""}: "#{
              unknown.select(&.starts_with?("-")).join("\", ")
            }"), true
          end
        end
      end

      @config = Config.get_config
      run args
    end

    def run(args)
      files = if args[0].includes? ":"
        resolve_index args[0]
      else
        resolve_path args[0]
      end

      Logger.error("no files found", true) if files.size == 0
      Logger.info "#{files.size} file#{files.size > 1 ? "s" : ""} found"

      complete = 0
      files.each_with_index do |file, index|
        Logger.info("deleting file (#{index + 1}/#{files.size})") if @verbose
        complete += safe_delete file
      end

      if complete == 0
        Logger.error "no files deleted"
        Logger.error("run with '--verbose' for additional info") unless @verbose
      else
        Logger.success "deleted #{complete} of #{files.size} files"
      end
    end

    def safe_delete(path) : Int32
      begin
        File.delete path
        1
      rescue ex
        if @verbose
          Logger.error ["failed to delete", ex.to_s]
        else
          Logger.error "failed to delete; skipped"
        end
        0
      end
    end

    private def resolve_index(str) : Array(String)
      base, index = str.split ":"
      base = base.try &.to_i
      index = index.try &.to_i
      Logger.error [
        "invalid archive index pattern",
        "format: dir_index:file_index (e.g. 2:3)"
      ] unless base && index

      dirs = Dir.glob("#{@config.archive_dir}#{File::SEPARATOR}*").select! { |f| Dir.exists? f }
      Logger.error("directory index out of range (#{base}/#{dirs.size - 1})", true) unless dirs[base]?

      full = Path[@config.archive_dir].join(dirs[base]).to_s
      files = Dir.glob "#{full}#{File::SEPARATOR}*"
      Logger.error("file index out of range (#{index}/#{files.size - 1})", true) unless files[index]?

      [files[index]]
    end

    private def resolve_recursive(dir, path, stack = 0) : Array(String)
      raise "maximum stack depth" if stack == 5

      files = Dir.glob "#{dir}#{File::SEPARATOR}*"
      files.each do |file|
        return [file] if file.ends_with? path
        if File.directory? file
          res = resolve_recursive file, path, stack + 1
          return res if res.size != 0
        end
      end

      [] of String
    end

    private def resolve_path(path) : Array(String)
      case path
      when /16\d{8}(?:\.json)?/
        path += ".json" unless path.ends_with? ".json"
        res = File.expand_path path, @config.archive_dir
        unless File.exists? res
          if @recursive
            res = resolve_recursive @config.archive_dir, path
            return res if res.size != 0
          else
            Logger.error [
              "no files found",
              "use '--recursive' or '-r' to perform deep search"
            ], true
          end
          [] of String
        else
          [res]
        end
      when /\d{4}-\d{2}-\d{2}\/\*/
        res = File.expand_path path, @config.archive_dir
        return Dir.glob(res) if Dir.exists? res[..-2]
        [] of String
      when /\d{4}-\d{2}-\d{2}\/16\d{8}(?:\.json)?/
        res = File.expand_path path, @config.archive_dir
        return [res] if File.exists? res
        [] of String
      else
        Logger.error "invalid file or directory path", true
        # for type checking
        [] of String
      end
    end
  end
end
