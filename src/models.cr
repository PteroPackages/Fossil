module Fossil::Models
  abstract struct Base
    include JSON::Serializable
  end

  struct FractalItem(T) < Base
    getter object : String
    getter attributes : T
  end

  struct Pagination < Base
    getter count : Int32
    getter total : Int32
    getter per_page : Int32
    getter current_page : Int32
    getter total_pages : Int32
  end

  # TODO: get rid of this...
  struct Wrapper < Base
    getter pagination : Pagination
  end

  struct FractalList(T) < Base
    getter object : String
    getter data : Array(FractalItem(T))
    getter meta : Wrapper
  end

  struct User < Base
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
