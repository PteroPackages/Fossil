require "json"

module Fossil::Models
  struct ItemWrapper(T)
    include JSON::Serializable

    property object     : String
    property attributes : T
  end

  struct DataWrapper(T)
    include JSON::Serializable

    property object : String
    property data   : Array(T)
  end

  struct ApiError
    include JSON::Serializable

    property code   : String
    property status : String
    property detail : String
  end

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

  struct Server
    include JSON::Serializable

    property identifier : String
    property uuid       : String
    property name       : String
  end

  struct SignedUrl
    include JSON::Serializable

    property url : String
  end

  struct Download
    property name : String
    property size : Int32

    def initialize(@name, @size)
      @data = uninitialized Slice(String)
    end

    def data : Slice(String)
      @data
    end

    def data=(buffer)
      @data = Slice(String).new @size, buffer
    end
  end
end
