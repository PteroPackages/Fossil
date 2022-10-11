require "./spec_helper"

describe Fossil do
  it "gets the version" do
    io = IO::Memory.new
    Fossil::Log.stdout = io
    Fossil.run ["-v"]

    io.to_s.should eq "Fossil versin #{Fossil::VERSION}"
  end
end
