module Fossil::Commands
  class Env < Base
    def setup : Nil
      @name = "env"

      add_argument "name"
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      if name = arguments.get?("name")
        case name.as_s
        when "cache"
          info Fossil::Config::CACHE_DIR
        when "lib", "library"
          info Fossil::Config::LIBRARY_DIR
        end
      else
        info "cache: #{Fossil::Config::CACHE_DIR}"
        info "library: #{Fossil::Config::LIBRARY_DIR}"
      end
    end
  end
end
