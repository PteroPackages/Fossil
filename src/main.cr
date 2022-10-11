require "./fossil"

begin
  Fossil.run ARGV
rescue ex : Fossil::Error
  ex.print_log
rescue Fossil::SystemExit
rescue ex
  Fossil::Error.new(:uncaught, ex).print_log
end
