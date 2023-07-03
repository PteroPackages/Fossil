module Fossil::Commands
  class Env < Base
    def setup : Nil
      @name = "env"
      @summary = "fossil environment management"
      @description = <<-DESC
        Manages the Fossil environment (system paths). Specify a Fossil environment name
        to print out its path.
        DESC

      add_usage "fossil env [name] [options]"
      add_usage "fossil env init [options]"

      add_command Init.new

      add_argument "name", description: "the name of the fossil environment"
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
      @summary = "initialize the fossil environment"
      @description = "Initializes the system paths and configuration file for Fossil."

      add_usage "fossil env init [options]"
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
      return unless File.exists? conf

      begin
        File.touch conf
      rescue ex
        error "Failed to create Fossil configuration file:"
        error ex
      end
    end
  end
end
