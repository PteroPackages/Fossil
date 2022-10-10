module Fossil::Commands
  class SetupCommand < CLI::Command
    include Base

    def setup : Nil
      @name = "setup"
      @description = "Sets up Fossil configurations and directories."
    end

    def execute(args, options) : Nil
      if Dir.exists? Config.config_path.parent
        Log.info "Found config directory (#{Config.config_path.parent})"
      else
        Log.info "Creating config directory: #{Config.config_path.parent}"

        begin
          Dir.mkdir_p Config.config_path.parent
        rescue File::AccessDeniedError
          Log.error [
            "Failed to create config directory: missing permissions",
            "Please create this directory separately for Fossil to operate"
          ]
        end
      end

      if File.exists? Config.config_path
        Log.info "Found config file (#{Config.config_path})"
      else
        Log.info "Creating config file: #{Config.config_path}"

        begin
          Config.write_template
        rescue File::AccessDeniedError
          Log.error [
            "Failed to create config file: missing permissions",
            "Please create this file separately for Fossil to operate"
          ]
        end
      end

      if Dir.exists? Config.cache_path
        Log.info "Found cache directory (#{Config.cache_path})"
      else
        Log.info "Creating cache directory: #{Config.cache_path}"

        begin
          Dir.mkdir_p Config.cache_path
        rescue File::AccessDeniedError
          Log.error [
            "Failed to create cache directory: missing permissions",
            "Please create this directory separately for Fossil to operate"
          ]
        end
      end

      if Dir.exists? Config.archive_path
        Log.info "Found archive directory (#{Config.archive_path})"
      else
        Log.info "Creating archive directory: #{Config.archive_path}"

        begin
          Dir.mkdir_p Config.archive_path
        rescue File::AccessDeniedError
          Log.error [
            "Failed to create archive directory: missing permissions",
            "Please create this directory separately for Fossil to operate"
          ]
        end
      end
    end
  end
end
