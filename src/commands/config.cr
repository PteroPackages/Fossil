module Fossil::Commands
  class Config
    def initialize(args, opts)
      send_help unless args[0]?

      case args[0]
      when "show"
        show_config
      when "set"
        set_config args
      when "init"
        init_config nil
      when "reset"
        reset_config
      else
        Logger.error "unknown subcommand '#{args[0]}'", true
      end
    end

    def send_help
      STDOUT << <<-HELP
      Commands for managing the Fossil config

      Usage:
          fossil config [options] <command>

      SubCommands:
          show    shows the current config
          init    initializes a new config
          set     sets a key in the config
          reset   resets the config setup

      Options:
          -f, --force don't prompt the user to continue
      HELP

      exit 0
    end

    def self.get_config : Models::Config
      unless path = ENV["FOSSIL_PATH"]?
        Logger.error "environment variable 'FOSSIL_PATH' is not set", true
      end

      unless File.exists? path.not_nil!
        Logger.error "environment variable 'FOSSIL_PATH' is an invalid path", true
      end

      file = File.read Path[path.not_nil!].join "config.yml"
      Models::Config.from_yaml file
    end

    def show_config
      cfg = self.class.get_config

      STDOUT << <<-CFG
      domain:      #{cfg.domain}
      api key:     #{cfg.auth}
      file format: #{cfg.format}
      archive dir: #{cfg.archive_dir}
      export dir:  #{cfg.export_dir}
      cache dir:   #{cfg.cache_dir}

      CFG
    end

    def init_config(dir : String?)
      unless File.exists? "#{__DIR__}/../config.tmpl.ecr"
        Logger.error [
          "missing template confir ecr file to continue",
          "please reinstall Fossil to fix this, or manually add the file"
        ], true
      end

      basedir : String
      if dir.nil?
        {% if flag?(:win32) %}
        basedir = "C:\\Program Files\\Fossil"
        {% else %}
        basedir = "/usr/lib/fossil"
        {% end %}
      else
        basedir = dir
      end

      archive_dir = Path[basedir].join "archive"
      export_dir = Path[basedir].join "export"
      cache_dir = Path[basedir].join "cache"
      [basedir, archive_dir, export_dir, cache_dir].each do |path|
        Dir.mkdir_p(path) unless Dir.exists? path
      end

      tmpl = ECR.render "#{__DIR__}/../config.tmpl.ecr"
      File.write Path[basedir].join("config.yml"), tmpl

      Logger.success [
        "created a new fossil space at:",
        File.expand_path basedir
      ]
    end

    def set_config(args)
      key, value = args[1]?, args[2]?
      unless key && value
        STDOUT << <<-HELP
        Usage:
            fossil config set <key> <value>

        Options:
            domain        the domain url of the panel
            auth          the application api key
            archive       the path to the archive directory
            format        the file format to write archives
            archive_dir   the path to the archive directory
            export_dir    the path to the exports directory
            cache_dir     the path to the cache directory

        HELP

        exit
      end

      cfg = self.class.get_config
      unless cfg[key]?
        Logger.error "invalid config option '#{key}'", true
      end

      case key.downcase
      when "format"
        unless ["json", "yaml", "yml"].includes? value.downcase
          Logger.error "invalid file format '#{value}'", true
        end
      when "archive_dir", "export_dir", "cache_dir"
        unless Dir.exists? value
          Logger.error "invalid #{key[..-4]} directory", true
        end
      end

      cfg[key] = value
      path = Path[ENV["FOSSIL_PATH"]].join "config.yml"
      File.write path, cfg.to_yaml

      Logger.success "updated the config"
    end

    def reset_config
      if path = ENV["FOSSIL_PATH"]?
        file = Path[path].join("config.yml").to_s
        if File.exists? file
          begin
            File.delete file
          rescue ex
            Logger.error ex.to_s, true
          end
        end
      end

      init_config path
    end
  end
end
