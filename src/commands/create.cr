require "option_parser"
require "../models.cr"

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
        parser.on("-u", "--users", "archives all user accounts") { @scopes << "users" }
        parser.on("-s", "--servers", "archives all servers") { @scopes << "servers" }
        parser.on("-n", "--nodes", "archives all nodes") { @scopes << "nodes" }

        parser.unknown_args do |unknown, _|
          if unknown.size != 0
            Logger.error %(unknown option#{
              unknown.size > 1 ? "s" : ""
            }: "#{unknown.join("\", ")}"), true
          end
        end
      end

      unless @scopes.size != 0
        Logger.error "at least 1 scope must be provided to archive", true
      end

      @config = Config.fetch
      @request = Request.new @config
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

    {% for key, model in {
      "users" => Models::User,
      "servers" => Models::Server,
      "nodes" => Models::Node
    } %}
    def exec_{{ key.id }} : Array({{ model }})
      Logger.info "fetching data..."
      res = @request.loop_get "/api/application/{{ key.id }}"
      Logger.info "received payload: %d bytes" % res.map(&.bytesize).reduce { |a, i| a + i }

      begin
        parsed = Array({{ model }}).new
        res.each_with_index do |str, page|
          Logger.info "loading page (%d/%d)" % [page + 1, res.size]

          obj = Array(Models::Wrap({{ model }})).from_json str, root: "data"
          obj.each_with_index do |o, i|
            Logger.info "parsing object (%d/%d)" % [i + 1, obj.size]
            parsed << o.attributes
          end
        end

        parsed
      rescue ex
        Logger.error ex
        [] of {{ model }}
      end
    end
    {% end %}
  end
end
