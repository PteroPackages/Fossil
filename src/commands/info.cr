module Fossil::Commands
  class Info < Base
    def setup : Nil
      @name = "info"

      add_argument "id"
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      archives = Dir.children Fossil::Config::LIBRARY_DIR
      if archives.empty?
        error "No archives found"
        system_exit
      end

      id = arguments.get("id").as_s
      name = case id
             when "first", "latest"
               archives.first
             when "last"
               archives.last
             else
               if archives.includes? id
                 id
               else
                 error "No archive with that ID found"
                 system_exit
               end
             end

      path = Fossil::Config::LIBRARY_DIR / name
      archive = uninitialized Archive

      File.open(path) do |file|
        Compress::Gzip::Reader.open(file) do |gzip|
          Crystar::Reader.open(gzip) do |tar|
            tar.each_entry do |entry|
              next unless entry.name.ends_with? "-archive.json"
              archive = Archive.from_json entry.io
              break
            end
          end
        end
      end

      info <<-INFO
        ID:      #{archive.id}
        Created: #{Time.unix archive.timestamp}
        Scopes:  #{archive.scopes.join ", "}
        Files:
          - #{archive.files.join("\n - ")}
        INFO
    end
  end
end
