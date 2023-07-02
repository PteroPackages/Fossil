require "cling"
require "colorize"
require "compress/gzip"
require "crest"
require "crystar"
require "ecr/macros"
require "file_utils"
require "json"
require "uri"

require "./archive"
require "./commands/*"
require "./config"
require "./errors"
require "./handler"
require "./log"
require "./models"

Colorize.on_tty_only!

module Fossil
  VERSION = "1.0.0"

  class App < Commands::Base
    def setup : Nil
      @name = "main"

      add_command Commands::Config.new
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      stdout.puts help_template
    end

    # def help_template
    #   <<-HELP
    #   Fossil - Pterodactyl Archive Manager

    #   Usage:
    #           fossil [options] <command> [arguments]

    #   Commands:
    #           list      lists existing archives
    #           create    creates an archive from the panel
    #           info      gets information about an archive
    #           restore   restores an archive to the panel
    #           delete    deletes existing archives
    #           setup     setup fossil configurations
    #           config    fossil config management

    #   Global Options:
    #           --no-color      disable ansi color codes
    #           --trace         log error stack traces
    #           -h, --help      get help information
    #           -v, --version   get the current version
    #   HELP
    # end
  end
end
