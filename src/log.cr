module Fossil::Log
  extend self

  def info(data : _) : Nil
    STDOUT.puts %(#{"Info".colorize(:blue)}: #{data})
  end

  def info(data : Array(_)) : Nil
    data.each { |d| info(d) }
  end

  def notice(data : _) : Nil
    STDOUT.puts %(#{"Notice".colorize(:cyan)}: #{data})
  end

  def notice(data : Array(_)) : Nil
    data.each { |d| notice(d) }
  end

  def warn(data : _) : Nil
    STDOUT.puts %(#{"Warn".colorize(:yellow)}: #{data})
  end

  def warn(data : Array(_)) : Nil
    data.each { |d| warn(d) }
  end

  def error(data : _) : Nil
    STDERR.puts %(#{"Error".colorize(:red)}: #{data})
  end

  def error(data : Array(_)) : Nil
    data.each { |d| error(d) }
  end

  def fatal(data : _) : NoReturn
    error data
    raise SystemExit.new
  end
end
