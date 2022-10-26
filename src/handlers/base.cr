module Fossil::Handlers
  abstract class BaseHandler
    getter config : Config

    def initialize(@config : Config)
    end

    protected def get_headers : Hash(String, String)
      {
        "User-Agent" => "Fossil Client v#{VERSION}",
        "Authorization" => "Bearer #{@config.key}",
        "Content-Type" => "application/json",
        "Accept" => "application/json",
      }
    end

    protected def route(path : String) : String
      "#{@config.url}/api/#{path}"
    end

    abstract def create(*, exclude : Bool = false, ids : Array(Int32)? = nil,
                        from : Int32? = nil, to : Int32? = nil) : Array(Archive::Source)

    abstract def restore : Nil
  end
end
