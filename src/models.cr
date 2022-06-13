require "json"

module Fossil::Models
  # Represents a fractal single item wrapper object.
  struct ItemWrapper(T)
    include JSON::Serializable

    property object     : String
    property attributes : T
  end

  # Represents a fractal list item wrapper object.
  struct DataWrapper(T)
    include JSON::Serializable

    property object : String
    property data   : Array(T)
  end

  # Represents a Pterodactyl API error.
  struct ApiError
    include JSON::Serializable

    property code   : String
    property status : String
    property detail : String
  end

  # Represents a server backup.
  struct Backup
    include JSON::Serializable

    property uuid           : String
    property name           : String
    property is_successful  : Bool
    property is_locked      : Bool
    property ignored_files  : Array(String)
    property checksum       : String?
    property bytes          : Int64
    property created_at     : Time
    property completed_at   : Time?
  end

  # Represents a server (partial data).
  struct Server
    include JSON::Serializable

    property identifier : String
    property uuid       : String
    property name       : String
  end

  # Represents a signed download URL object.
  struct SignedUrl
    include JSON::Serializable

    property url : String
  end

  # Represents a Fossil downloaded file object, containing the file name, size,
  # and buffered data.
  struct Download
    property name : String
    property size : Int32

    # :nodoc:
    def initialize(@name, @size)
      @data = uninitialized Slice(String)
    end

    # :nodoc:
    def data : Slice(String)
      @data
    end

    # :nodoc:
    def data=(buffer)
      @data = Slice(String).new @size, buffer
    end
  end
end
