module Fossil::Models
  struct FeatureLimits
    include JSON::Serializable

    getter allocations : Int32
    getter backups : Int32
    getter databases : Int32
  end

  struct FractalItem
    include JSON::Serializable

    use_json_discriminator "object", {nest: Nest, node: Node, user: User, server: Server}

    getter object : String
  end

  struct FractalList
    include JSON::Serializable

    getter object : String
    getter data : Array(FractalItem)
    @[JSON::Field(key: "meta", root: "pagination")]
    getter pagination : Pagination
  end

  struct Limits
    include JSON::Serializable

    getter memory : Int64
    getter swap : Int64
    getter disk : Int64
    getter io : Int64?
    getter threads : String?
    getter? oom_disabled : Bool = false
  end

  struct Nest
    include JSON::Serializable

    getter id : Int32
    getter uuid : String
    getter author : String
    getter name : String
    getter description : String?
    getter created_at : String
    getter updated_at : String?
  end

  struct Node
    include JSON::Serializable

    getter id : Int32
    getter name : String
    getter description : String?
    getter location_id : Int32
    getter? public : Bool
    getter fqdn : String
    getter scheme : String
    getter? behind_proxy : Bool
    getter memory : Int64
    getter memory_overallocate : Int64
    getter disk : Int64
    getter disk_overallocate : Int64
    getter daemon_base : String
    getter daemon_sftp : Int64
    getter daemon_listen : Int64
    getter? maintenance_mode : Bool
    getter upload_size : Int64
    getter created_at : String
    getter updated_at : String?
  end

  struct User
    include JSON::Serializable

    getter id : Int32
    getter external_id : String?
    getter uuid : String
    getter username : String
    getter email : String
    getter first_name : String
    getter last_name : String
    getter language : String
    getter? root_admin : Bool
    @[JSON::Field(key: "2fa")]
    getter? two_factor : Bool
    getter created_at : String
    getter updated_at : String?
  end

  struct Pagination
    include JSON::Serializable

    getter count : Int32
    getter total : Int32
    getter per_page : Int32
    getter current_page : Int32
    getter total_pages : Int32
  end

  struct Server
    include JSON::Serializable

    getter id : Int32
    getter external_id : String?
    getter uuid : String
    getter identifier : String
    getter name : String
    getter description : String?
    getter status : String?
    getter? suspended : Bool
    getter limits : Limits
    getter feature_limits : FeatureLimits
    getter user : Int32
    getter node : Int32
    getter allocation : Int32
    getter nest : Int32
    getter egg : Int32
    getter container
    getter created_at : String
    getter updated_at : String?
  end
end
