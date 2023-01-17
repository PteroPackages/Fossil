module Fossil::Commands
  class CreateCommand < BaseCommand
    def setup : Nil
      @name = "create"

      add_argument "type", description: "the specific type of archive to create", required: false
      add_option "users", description: "scope for archiving all users"
      add_option "servers", description: "scope for archiving all servers"
      add_option "nodes", description: "scope for archiving all nodes"
      add_option "nests", description: "scope for archiving all nests"
      add_option "compress", description: "compresses the archive into a single tar file"
    end

    def run(arguments, options) : Nil
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
          Error::PERM_NOTICE,
        ]
      end

      Log.info "Testing panel connection..."
      begin
        Crest.get cfg.url + "/sanctum/csrf-cookie"
      rescue ex
        Log.fatal ["Connection to the panel failed:", ex.to_s]
      end

      scopes = options.options.keys
      Log.info %(Creating archive with the following scope#{"s" if scopes.size > 1}: #{scopes.join ", "})
      archive = Archive.new scopes
      handler = Handler.new cfg

      archive.sources.concat handler.create_users if options.has? "users"
      archive.sources.concat handler.create_servers if options.has? "servers"
      archive.sources.concat handler.create_nodes if options.has? "nodes"
      archive.sources.concat handler.create_nests if options.has? "nests"

      if options.has? "compress"
        Log.info "Collected all objects, compressing..."

        path = dir / "archive.tar.gz"
        Compress::Gzip::Writer.open(path.to_s) do |gzip|
          archive.compress gzip
        end

        Log.notice ["📦 Archive complete", "Path: #{path}"]
      else
        Log.info "Collected all objects, saving..."
        archive.save dir

        Log.notice ["🗂️  Archive complete", "Directory: #{dir}", %(Lockfile:  #{dir / "archive.lock"})]
      end
    end
  end
end
