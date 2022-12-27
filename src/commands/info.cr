module Fossil::Commands
  class InfoCommand < BaseCommand
    def setup : Nil
      @name = "info"

      add_argument "id", desc: "the ID of the archive or a directive", required: true
    end

    def run(args, options) : Nil
      id = args.get!("id").as_s
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

      case Dir.children(Config.archive_path / arc)
      when .includes? "archive.tar.gz"
        format_compressed Config.archive_path / arc / "archive.tar.gz"
      when .includes? "archive.lock"
        format_standard Config.archive_path / arc / "archive.lock"
      else
        Log.fatal "Unknown archive format; lockfile or tarfile not found"
      end
    end

    private def format_compressed(path : Path) : Nil
      info = File.info path
      arc = uninitialized Archive

      File.open(path) do |file|
        Compress::Gzip::Reader.open(file) do |gzip|
          Crystar::Reader.open(gzip) do |tar|
            tar.each_entry do |entry|
              next unless entry.name == "archive.lock"
              arc = Archive.from_json entry.io
              break
            end
          end
        end
      end

      Log.info [
        "📦 " + "#{path.parts[-2]}#{File::SEPARATOR}archive.tar.gz".colorize.bold.to_s,
        "Created: #{arc.created_at}",
        "Size: #{info.size.humanize_bytes}",
        "Scopes: #{arc.scopes.join ", "}",
      ]
    end

    private def format_standard(path : Path) : Nil
      arc = Archive.from_json File.read path

      Log.info [
        "🗂️ " + "#{path.parts[-2]}#{File::SEPARATOR}archive.lock".colorize.bold.to_s,
        "Created: #{arc.created_at}",
        "Size: unknown (#{arc.files.size} file#{"s" if arc.files.size > 1})",
        "Scopes: #{arc.scopes.join ", "}",
      ]
    end
  end
end
