module Fossil::Commands
  class CreateCommand < BaseCommand
    def setup : Nil
      @name = "create"

      add_argument "type", desc: "the specific type of archive to create", required: false
      add_option "users", desc: "scope for archiving all users"
    end

    def run(args, options) : Nil
      if options.empty?
        Log.fatal [
          "At least one scope must be specified to create an archive",
          "See '$Bfossil create --help$R' for more information",
        ]
      end

      cfg = Config.fetch
      dir = Config.archive_path / Time.utc.to_s("%FT%T").gsub(":", "-")

      begin
        Dir.mkdir_p dir unless Dir.exists? dir
      rescue File::AccessDeniedError
        Log.fatal [
          "Failed to create archive directory: permission denied",
          "Make sure you are running this command #{{{ flag?(:win32) ? "with admin permissions" : "as root user" }}}",
        ]
      end

      Log.info "Testing panel connection..."
      begin
        Crest.get cfg.url + "/sanctum/csrf-cookie"
      rescue ex
        Log.fatal ["Connection to the panel failed:", ex.to_s]
      end

      Log.info "Creating archive with the following scope(s): #{options.options.keys.join(", ")}"
      archive = Archive.new
      handler = Handler.new cfg

      if options.has? "users"
        archive.sources.concat handler.create_users
      end

      archive.save dir
    end
  end
end
