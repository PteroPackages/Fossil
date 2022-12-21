module Fossil::Commands
  class ListCommand < BaseCommand
    def setup : Nil
      @name = "list"

      add_option "clean", desc: "formats the output without custom text"
    end

    def run(args, options) : Nil
      dir = Config.archive_path
      archives = [] of {String, Bool, Int32}

      Dir.each_child(dir) do |name|
        next unless Dir.exists?(dir / name)
        child = Dir.children(dir / name)

        if child.size == 1 && child[0] == "archive.tar.gz"
          archives << {name, true, 1}
        else
          archives << {name, false, child.size}
        end
      end

      if options.has? "clean"
        archives.each do |(name, comp, size)|
          Log.write %(#{name} (#{size}) #{comp ? "compressed" : "standard"})
        end
      else
        Log.info ["🗂️  - standard archive", "📦 - compressed archive"]
        archives.each do |(name, comp, size)|
          Log.write %(#{comp ? "📦" : "🗂️ "} (#{size}) > #{name})
        end
      end
    end
  end
end
