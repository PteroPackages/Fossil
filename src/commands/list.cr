module Fossil::Commands
  class List < Base
    def setup : Nil
      @name = "list"
      @summary = "list existing archives"
      @description = "Lists all existing archives in the system."

      add_usage "fossil list [options]"
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      archives = Dir.children(Fossil::Config::LIBRARY_DIR).select &.ends_with? ".tar.gz"
      archives.each { |a| info a }
    end
  end
end
