module Fossil::Commands
  class Create < Base
    def setup : Nil
      @name = "create"
      @summary = "create an archive"
      @description = <<-DESC
        Creates an archive with the specified scope flags. At least one scope must be
        specified to create an archive.
        DESC

      add_usage "fossil create <scope...> [options]"

      add_option "users", description: "scope for archiving all users"
      add_option "servers", description: "scope for archiving all servers"
      add_option "nodes", description: "scope for archiving all nodes"
      add_option "nests", description: "scope for archiving all nests"
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      if options.empty?
        error "At least one scope must be specified to create an archive"
        error "See 'fossil create --help' for a list of available scopes"
        system_exit
      end

      Fossil::Config.load

      begin
        HTTP.test_connection
      rescue ex
        error "Connection to the panel failed:"
        error ex
        system_exit
      end

      id = Random.new(Time.utc.to_unix).hex
      path = Fossil::Config::LIBRARY_DIR / (id + ".tar.gz")
      file = File.open path, mode: "w"
      scopes = options.hash.keys

      info "Creating archive with the following scopes:"
      info scopes.join ", "
      info ""

      archive = Archive.new id, scopes
      archive.sources.concat HTTP.create_user_source(id) if options.has? "users"
      archive.sources.concat HTTP.create_server_source(id) if options.has? "servers"
      archive.sources.concat HTTP.create_node_source(id) if options.has? "nodes"
      archive.sources.concat HTTP.create_nest_source(id) if options.has? "nests"

      Compress::Gzip::Writer.open(file) do |gzip|
        archive.compress gzip
      end
      file.close

      info "📦 Archive complete"
      info "Path: #{path}"
    end
  end
end
