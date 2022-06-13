require "spec"
require "../src/fossil"

describe Fossil do
  it "gets the version" do
    Fossil.run ["-v"]
  end

  it "fetches the config" do
    Fossil::Commands::Config.run([] of String)
  end
end
