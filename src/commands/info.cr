module Fossil::Commands
  class InfoCommand < BaseCommand
    def setup : Nil
      @name = "info"

      add_argument "id", desc: "the ID of the archive or a directive", required: true
    end

    def run(args, options) : Nil
      id = args.get!("id").as_s
      archives = Dir.children Config.archive_path
      name = case id
      when "first"
        archives.first
      when "last", "latest"
        archives.last
      else
        archives.find { |a| a == id } || Log.fatal "No archive with that ID found"
      end

      case Dir.children(Config.archive_path / name)
      when .includes? "archive.tar.gz"
        format_compressed name
      when .includes? "archive.lock"
        format_standard name
      else
        Log.fatal "Unknown archive format; lockfile or tarfile not found"
      end
    end

    private def format_compressed(name : String) : Nil
      Log.notice ["📦 " + "#{name}/archive.tar.gz".colorize.bold.to_s]
    end

    private def format_standard(name : String) : Nil
      Log.notice ["🗂️ " + "#{name}/archive.lock".colorize.bold.to_s]
    end
  end
end
