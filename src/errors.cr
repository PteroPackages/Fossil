module Fossil
  class Error < Exception
    enum Kind
      Uncaught
      None
    end

    getter kind : Kind

    def initialize(@kind : Kind, message : String)
      super message
    end

    def initialize(@kind : Kind, cause : Exception)
      super cause: cause
    end

    def format_log(fatal : Bool = false) : Nil
      case @kind
      in Kind::Uncaught
        Log.error [
          "an unexpected error occured, please report this to the PteroPackages team",
          "context: #{message}"
        ] + inspect_with_backtrace.lines
      in Kind::None
      end

      raise SystemExit.new if fatal
    end
  end

  class SystemExit < Exception
  end
end
