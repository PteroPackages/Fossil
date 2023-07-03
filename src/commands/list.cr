module Fossil::Commands
  class List < Base
    def setup : Nil
      @name = "list"

      add_option "clean", description: "formats the output without custom text"
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      archives = Dir.children(Fossil::Config::LIBRARY_DIR).select &.ends_with? ".tar.gz"
      archives.each { |a| info a }
    end
  end
end
