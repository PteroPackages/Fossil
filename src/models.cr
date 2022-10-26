module Fossil::Models
  abstract struct BaseModel
  end

  struct FractalItem(T) < BaseModel
    include JSON::Serializable

    getter object : String
    getter attributes : T
  end

  struct Metadata < BaseModel
    include JSON::Serializable

    getter count : Int32
    getter total : Int32
    getter per_page : Int32
    getter current_page : Int32
    getter total_pages : Int32
    getter links : Hash(String, String)
  end

  struct FractalList(T) < BaseModel
    include JSON::Serializable

    getter object : String
    getter data : Array(FractalItem(T))
    @[JSON::Field(key: "pagination", root: "meta")]
    getter meta : Metadata
  end

  struct User < BaseModel
    include JSON::Serializable

    getter id : Int32
    getter external_id : String?
    getter uuid : String
    getter username : String
    getter email : String
    getter first_name : String
    getter last_name : String
    getter language : String
    getter root_admin : Bool
    @[JSON::Field(key: "2fa")]
    getter two_factor : Bool
    getter created_at : String
    getter updated_at : String?
  end
end
