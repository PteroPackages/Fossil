module Fossil::Commands
  class Env < Base
    def setup : Nil
      @name = "env"

      add_command Init.new

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

  class Init < Base
    def setup : Nil
      @name = "init"
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      unless Dir.exists? Fossil::Config::CACHE_DIR
        begin
          Dir.mkdir_p Fossil::Config::CACHE_DIR
        rescue ex
          error "Failed to create Fossil cache directory:"
          error ex
        end
      end

      unless Dir.exists? Fossil::Config::LIBRARY_DIR
        begin
          Dir.mkdir_p Fossil::Config::LIBRARY_DIR
        rescue ex
          error "Failed to create Fossil library directory:"
          error ex
        end
      end

      conf = Fossil::Config::CACHE_DIR / "fossil.conf"
      unless File.exists? conf
        begin
          File.touch conf
        rescue ex
          error "Failed to create Fossil configuration file:"
          error ex
        end
      end
    end
  end
end
