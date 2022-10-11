module Fossil::Log
  extend self

  class_property stdout : IO = STDOUT
  class_property stderr : IO = STDERR

  def write(data : _) : Nil
    stdout.puts data
  end

  def write(data : Array(_)) : Nil
    data.each { |d| write(d) }
  end

  def info(data : _) : Nil
    stdout.puts %(#{"Info".colorize(:blue)}: #{data})
  end

  def info(data : Array(_)) : Nil
    data.each { |d| info(d) }
  end

  def notice(data : _) : Nil
    stdout.puts %(#{"Notice".colorize(:cyan)}: #{data})
  end

  def notice(data : Array(_)) : Nil
    data.each { |d| notice(d) }
  end

  def warn(data : _) : Nil
    stdout.puts %(#{"Warn".colorize(:yellow)}: #{data})
  end

  def warn(data : Array(_)) : Nil
    data.each { |d| warn(d) }
  end

  def error(data : _) : Nil
    stderr.puts %(#{"Error".colorize(:red)}: #{data})
  end

  def error(data : Array(_)) : Nil
    data.each { |d| error(d) }
  end

  def fatal(data : _) : NoReturn
    error data
    raise SystemExit.new
  end
end
