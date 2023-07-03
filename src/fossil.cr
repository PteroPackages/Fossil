require "cling"
require "colorize"
require "compress/gzip"
require "crest"
require "crystar"
require "json"
require "uri"

require "./archive"
require "./commands/*"
require "./config"
require "./http"
require "./models"
require "./progress"

Colorize.on_tty_only!

module Fossil
  VERSION = "1.0.0"

  class App < Commands::Base
    def setup : Nil
      @name = "main"
      @description = "Pterodactyl archive manager"

      add_usage "fossil <command> [options] <arguments>"

      add_command Commands::List.new
      add_command Commands::Info.new
      add_command Commands::Create.new
      # add_command Commands::Restore.new
      # add_command Commands::Delete.new
      add_command Commands::Config.new
      add_command Commands::Env.new
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      stdout.puts help_template
    end
  end

  class SystemExit < Exception
  end
end
