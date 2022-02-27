require "json"
require "yaml"

module Fossil::Models
  abstract struct Base
    include JSON::Serializable
    include YAML::Serializable
  end

  struct Wrap(T) < Base
    property object     : String
    property attributes : T
  end

  struct Archive < Base
    property created_at   : String
    property scopes       : Array(String)
    property users        : Array(User)?

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
end
