require "option_parser"

module Fossil::Commands
  class Create
    property debug : Bool
    property scopes : Array(String)
    property config : Config
    property request : Request

    def initialize(scopes, options)
      @debug = false
      @scopes = scopes
      @config = Config.fetch
      @request = Request.configure @config

      run options
    end

    def self.run(args : Array(String), opts : CmdOptions)
      scopes = [] of String
      puts args

      OptionParser.parse(args) do |parser|
        parser.on("-u", "--users", "archives all user accounts") { puts true;scopes << "users" }
        parser.on("-s", "--servers", "archives all servers") { scopes << "servers" }
        parser.on("-n", "--nodes", "archives all nodes") { scopes << "nodes" }
        parser.on("-a", "--allocs", "archices all allocations") { scopes << "allocations" }
        parser.on("-h", "--help", "sends help!") do
          puts <<-HELP
          Usage:
              fossil create [options] [scopes]

          Options:
              -u, --users     archives all user accounts
              -s, --servers   archives all servers
              -n, --nodes     archives all nodes
              -a, --allocs    archives all allocations
              --export
              -v, --verbose
              -h, --help      sends help!
          HELP

          exit 0
        end

        parser.unknown_args do |unknown, options|
          puts unknown
          Logger.error %(unknown option "#{unknown.join("\", \"")}"), true
        end

        if scopes.size == 0
          Logger.error "at least 1 scope must be provided to archive", true
        end

        new scopes, opts
      end
    end

    def run(opts)
      @request = Request.configure @config
      path = Path.new config.archive_dir, Time.utc.to_s "%F"
      Dir.mkdir_p path
      path = path / Time.utc.to_s "%s.json"
      Logger.banner

      archive = Models::Archive.new scopes
      @scopes.each do |scope|
        Logger.info "creating archives for " + scope

        case scope
        when "users"
          archive.users = exec_users
        end
      end

      Logger.info "finalizing..."
      File.write path, archive.to_json
      Logger.success [
        "request complete! archive can be found here:",
        path.to_s
      ]
    end

    def log_debug(message)
      return unless @debug
      Logger.debug message
    end

    def exec_users : Array(Models::User)
      Logger.info "fetching metadata..."

      res = @request.get "/api/application/users"
      Logger.info "received payload: %d bytes" % res.bytesize

      begin
        parsed = Array(Models::User).new
        users = Array(Models::Wrap(Models::User)).from_json res, root: "data"

        users.each_with_index do |user, index|
          Logger.info "parsing object (%d/%d)" % [index + 1, users.size]
          # TODO: add patch checker
          parsed << user.attributes
        end

        Logger.info "finalizing..."
        parsed
      rescue ex
        Logger.error ex
        [] of Models::User
      end
    end
  end
end
