require "./fossil"

begin
  Fossil::App.new.execute ARGV
rescue Fossil::SystemExit
end
