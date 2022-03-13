require "json"
require "yaml"

module Fossil::Models
  abstract struct Base
    include JSON::Serializable
    include YAML::Serializable
  end

  struct Config < Base
    property domain   : String
    property auth     : String
    property archive  : String
    property formats  : Hash(String, String)
  end

  struct Response < Base
    @[JSON::Field(key: "pagination", root: "meta")]
    property meta : MetaData?
  end

  struct Wrap(T) < Base
    property object     : String
    property attributes : T
  end

  struct MetaData < Base
    property total        : Int64
    property count        : Int64
    property per_page     : Int64
    property current_page : Int64
    property total_pages  : Int64
    property links        : Hash(String, String)
  end

  struct Archive < Base
    property created_at   : String
    property scopes       : Array(String)
    property users        : Array(User)?
    property servers      : Array(Server)?
    property nodes        : Array(Node)?
    property locations    : Array(Location)?

    def initialize(@scopes)
      @created_at = Time.utc.to_s "%s"
    end
  end

  struct User < Base
    property id           : Int64
    property external_id  : String?
    property uuid         : String
    property username     : String
    property email        : String
    property first_name   : String
    property last_name    : String
    property language     : String
    property root_admin   : Bool
    @[JSON::Field(key: "2fa")]
    property two_factor   : Bool
    property created_at   : Time
    property updated_at   : Time?
  end

  struct Server < Base
    property id             : Int64
    property external_id    : String?
    property uuid           : String
    property identifier     : String
    property name           : String
    property description    : String?
    property suspended      : Bool
    property limits         : ServerLimits
    property feature_limits : Hash(String, Int64)
    property user           : Int64
    property node           : Int64
    property allocation     : Int64
    property nest           : Int64
    property egg            : Int64
    @[JSON::Field(ignore: true)]
    property pack           : Nil
    property container      : ServerContainer
    property created_at     : Time
    property updated_at     : Time?
  end

  struct ServerLimits < Base
    property memory  : Int64
    property swap    : Int64
    property disk    : Int64
    property io      : Int64
    property cpu     : Int64
    property threads : String?
  end

  struct ServerContainer < Base
    property startup_command : String
    property image           : String
    property installed       : Int64
    property environment     : Hash(String, String | Int64)
  end

  struct Node < Base
    property id                   : Int64
    property uuid                 : String
    property public               : Bool
    property name                 : String
    property description          : String?
    property location_id          : Int64
    property fqdn                 : String
    property scheme               : String
    property behind_proxy         : Bool
    property maintenance_mode     : Bool
    property memory               : Int64
    property memory_overallocate  : Int64
    property disk                 : Int64
    property disk_overallocate    : Int64
    property upload_size          : Int64
    property daemon_listen        : Int64
    property daemon_sftp          : Int64
    property daemon_base          : String
    property created_at           : Time
    property updated_at           : Time?
  end

  struct Location < Base
    property id         : Int64
    property short      : String
    property long       : String
    property created_at : Time
    property updated_at : Time?
  end
end
