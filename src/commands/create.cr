require "crest"

module Fossil::Commands
  class Create
    def self.run(args : Array(String), opts : CmdOptions)
      # TODO: parse flags

      config = Config.fetch
      path = Path.new config.archive_dir, Time.utc.to_s "%F"
      Dir.mkdir_p path
      path = path / Time.utc.to_s "%s.json"

      Logger.banner
      Logger.info "fetching metadata..."

      req = Request.configure config
      res = req.get "/api/application/users"
      Logger.info "received payload: %d bytes" % res.bytesize

      error = false
      begin
        parsed = Array(Models::User).new
        users = Array(Models::User).from_json res, root: "data"

        users.each_with_index do |user, index|
          Logger.info "parsing object %d/%d" % [index, users.size]
          # TODO: add patch checker
          parsed << user
        end

        Logger.info "finalizing..."
        File.write path, parsed.to_json
        Logger.info [
          "request complete!",
          "archive can be found here:",
          path.to_s
        ]
      rescue ex
        error = true
        Logger.error ex
      ensure
        File.delete(path) if error
      end
    end
  end
end
