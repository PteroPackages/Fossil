module Fossil
  class Error < Exception
    enum Kind
      Uncaught
      ConfigNotFound
      ConfigNotSet
      ConfigWriteDenied
      ConfigInvalidUrl
      ConfigInvalidKey
    end

    getter kind : Kind

    def initialize(@kind : Kind, cause : Exception? = nil)
      super cause: cause
    end

    def print_log(fatal : Bool = false) : Nil
      case @kind
      in Kind::ConfigNotFound
        Log.error [
          "The Fossil config file could not be found",
          "Run the '$Bfossil setup$R' command to setup Fossil configurations",
        ]
      in Kind::ConfigNotSet
        Log.error [
          "The panel URL or API key has not been set for the config",
          "See '$Bfossil config --help$R' for more information",
        ]
      in Kind::ConfigWriteDenied
        Log.error [
          "Failed to write to config file: permission denied",
          "Make sure you are running this command #{{{ flag?(:win32) ? "with admin permissions" : "as root user" }}}",
        ]
      in Kind::ConfigInvalidUrl
        Log.error [
          "The panel URL set in the config is invalid",
          "Update this using the '$Bfossil config --set --url <url>$R' command",
        ]
      in Kind::ConfigInvalidKey
        Log.error [
          "The API key set in the config is invalid",
          "Update this using the '$Bfossil config --set --key <key>$R' command",
        ]
      in Kind::Uncaught
        Log.error [
          "An unexpected error occured, please report this to the PteroPackages team",
        ] + inspect_with_backtrace.lines
      end

      raise SystemExit.new if fatal
    end
  end

  class SystemExit < Exception
  end
end
