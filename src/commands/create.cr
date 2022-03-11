require "option_parser"

module Fossil::Commands
  class Create
    property scopes  : Array(String)
    property config  : Config
    property request : Request
    property debug   : Bool

    def initialize(args, options)
      @scopes = [] of String
      @debug = options.debug

      OptionParser.parse(args) do |parser|
        parser.on("-u", "--users", "") { @scopes << "users" }
        parser.on("-s", "--servers", "") { @scopes << "servers" }
        parser.on("-n", "--nodes", "") { @scopes << "nodes" }

        parser.unknown_args do |unknown, _|
          if unknown.size != 0
            Logger.error %(unknown option#{unknown.size > 1 ? "s" : ""}: "#{unknown.join("\", ")}"), true
          end
        end
      end

      unless @scopes.size != 0
        Logger.error "at least 1 scope must be provided to archive", true
      end

      @config = Config.fetch
      @request = Request.configure @config
      run
    end

    def run
      path = Path.new config.archive_dir, Time.utc.to_s "%F"
      Dir.mkdir_p path
      path /= Time.utc.to_s "%s.json"
      Logger.banner

      archive = Models::Archive.new @scopes
      @scopes.each do |scope|
        Logger.info "creating archive for " + scope

        case scope
        when "users"
          archive.users = exec_users
        when "servers"
          archive.servers = exec_servers
        when "nodes"
          archive.nodes = exec_nodes
        end
      end

      Logger.info "finalizing..."
      File.write path, archive.to_json
      Logger.success [
        "request complete! archive can be found here:",
        path.to_s
      ]
    end

    def exec_users : Array(Models::User)
      Logger.info "fetching data..."
      res = @request.loop_get "/api/application/users"
      Logger.info "received payload: %d bytes" % res.map(&.bytesize).reduce { |a, i| a + i }

      begin
        parsed = Array(Models::User).new
        res.each_with_index do |str, page|
          Logger.info "loading page (%d/%d)" % [page + 1, res.size]

          users = Array(Models::Wrap(Models::User)).from_json str, root: "data"
          users.each_with_index do |user, index|
            Logger.info "parsing object (%d/%d)" % [index + 1, users.size]
            parsed << user.attributes
          end
        end

        parsed
      rescue ex
        Logger.error ex
        [] of Models::User
      end
    end

    def exec_servers : Array(Models::Server)
      Logger.info "fetching data..."
      res = @request.loop_get "/api/application/servers"
      Logger.info "received payload: %d bytes" % res.map(&.bytesize).reduce { |a, i| a + i }

      begin
        parsed = Array(Models::Server).new
        res.each_with_index do |str, page|
          Logger.info "loading page (%d/%d)" % [page + 1, res.size]

          servers = Array(Models::Wrap(Models::Server)).from_json str, root: "data"
          servers.each_with_index do |server, index|
            Logger.info "parsing object (%d/%d)" % [index + 1, servers.size]
            parsed << server.attributes
          end
        end

        parsed
      rescue ex
        Logger.error ex
        [] of Models::Server
      end
    end

    def exec_nodes : Array(Models::Node)
      Logger.info "fetching data..."
      res = @request.loop_get "/api/application/nodes"
      Logger.info "received payload: %d bytes" % res.map(&.bytesize).reduce { |a, i| a + i }

      begin
        parsed = Array(Models::Node).new
        res.each_with_index do |str, page|
          Logger.info "loading page (%d/%d)" % [page + 1, res.size]

          nodes = Array(Models::Wrap(Models::Node)).from_json str, root: "data"
          nodes.each_with_index do |node, index|
            Logger.info "parsing object (%d/%d)" % [index + 1, nodes.size]
            parsed << node.attributes
          end
        end

        parsed
      rescue ex
        Logger.error ex
        [] of Models::Node
      end
    end
  end
end
