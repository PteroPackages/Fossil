require "cli"
require "colorize"

require "./commands/*"
require "./errors"
require "./log"

Colorize.on_tty_only!

module Fossil
  VERSION = "0.4.0" # old

  def self.run : Nil
    app = CLI::Application.new
    app.help_template = Commands::RootCommand.help_template

    app.run ARGV
  end
end

begin
  Fossil.run
rescue Fossil::SystemExit
rescue ex
  Fossil::Error.new(:uncaught, ex).format_log
end
