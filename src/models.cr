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

  struct Backup
    include JSON::Serializable

    property uuid : String
    property name : String
    property ignored_files : Array(String)
    # property hash : String
    property bytes : Int64
    property created_at : Time
    property completed_at : Time?
  end

  struct Server
    include JSON::Serializable

    property identifier : String
    property uuid       : String
    property name       : String
  end
end
