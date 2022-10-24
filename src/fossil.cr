require "cli"
require "colorize"
require "ecr/macros"
require "uri"

require "./commands/*"
require "./config"
require "./errors"
require "./log"

Colorize.on_tty_only!

module Fossil
  VERSION = "0.4.0" # old

  class App < Commands::BaseCommand
    def initialize
      super

      add_command Commands::ConfigCommand.new
      add_command Commands::SetupCommand.new

      add_option 'v', "version", desc: "get the current version"
    end

    def setup : Nil
      @name = "_main"
    end

    def help_template
      <<-HELP
      Fossil - Pterodactyl Archive Manager

      Usage:
              fossil [options] <command> [arguments]

      Commands:
              list      lists existing archives
              create    creates an archive from the panel
              status    gets the status of an archive
              restore   restores an archive to the panel
              delete    deletes existing archives
              setup     setup fossil configurations
              config    fossil config management

      Global Options:
              --no-color      disable ansi color codes
              --trace         log error stack traces
              -h, --help      get help information
              -v, --version   get the current version
      HELP
    end

    def pre_run(args, options)
      case options
      when .has? "help"
        stdout.puts help_template

        false
      when .has? "version"
        stdout.puts "Fossil version #{VERSION}"

        false
      else
        true
      end
    end

    def run(args, options) : Nil
      stdout.puts help_template
    end
  end
end
