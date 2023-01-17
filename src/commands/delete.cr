module Fossil::Commands
  class DeleteCommand < BaseCommand
    def setup : Nil
      @name = "delete"

      add_argument "id", description: "the ID of the archive or a directive", required: true
    end

    def run(arguments, options) : Nil
      id = arguments.get!("id").as_s
      archives = Dir.children Config.archive_path
      Log.fatal "No archives found" if archives.empty?

      arc = case id
            when "first"
              archives.first
            when "last", "latest"
              archives.last
            else
              archives.includes?(id) ? id : Log.fatal "No archive with that ID found"
            end

      FileUtils.rm_r Config.archive_path / arc
    rescue File::AccessDeniedError
      Log.fatal ["Failed to remove archive: permission denied", Error::PERM_NOTICE]
    end
  end
end
