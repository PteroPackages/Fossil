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

  def self.run(args : Array(String)) : Nil
    app = CLI::Application.new
    app.help_template = Commands::RootCommand.help_template

    app.add_command Commands::SetupCommand
    app.add_command Commands::ConfigCommand

    app.run args
  end
end

begin
  Fossil.run ARGV
rescue ex : Fossil::Error
  ex.format_log
rescue Fossil::SystemExit
rescue ex
  Fossil::Error.new(:uncaught, ex).format_log
end
