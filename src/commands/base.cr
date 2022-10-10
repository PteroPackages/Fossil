module Fossil::Commands::Base
  def on_invalid_options(options)
    Log.fatal [
      "invalid option#{"s" if options.size > 1} '#{options.join("', '")}'",
      "see 'fossil #{self.name} --help' for more information"
    ]
  end

  def on_missing_arguments(args)
    Log.fatal [
      "missing required argument#{"s" if args.size > 1} #{args.join(", ")}",
      "see 'fossil #{self.name} --help' for more information"
    ]
  end
end
