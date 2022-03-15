require "./spec_helper"

describe Fossil do
  options = Fossil::CmdOptions.new true, true

  it "sets the environment variable" do
    {% if flag?(:win32) %}
    `set FOSSIL_PATH=%CD%\\bin`
    {% else %}
    `export FOSSIL_PATH=$(pwd)/bin`
    {% end %}
  end

  it "initializes the config" do
    Fossil::Commands::Config.new ["init"], options
  end

  it "fetches the config" do
    Fossil::Commands::Config.new ["show"], options
  end
end
