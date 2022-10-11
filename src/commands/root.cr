module Fossil::Commands
  class RootCommand < CLI::Command
    def self.help_template : String
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

    def setup : Nil
      @name = "root"
      @help_template = self.class.help_template

      add_option "no-color"
      add_option "trace"
      add_option "help", short: "h"
      add_option "version", short: "v"
    end

    def execute(args, options) : Nil
      if options.has? "version"
        puts "Fossil version #{::Fossil::VERSION}"
      else
        puts help_template
      end
    end
  end
end
