class Fossil::Handler
  getter config : Config

  def initialize(@config)
  end

  def default_headers : Hash(String, String)
    {
      "User-Agent" => "Fossil Client v#{VERSION}",
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => "Bearer #{@config.key}"
    }
  end

  private def get_all_pages(route : String, type : T.class) : Array(Array(T)) forall T
    results = Crest.get "#{@config.url}/api/application/#{route}", headers: default_headers
    data = Models::FractalList(T).from_json results.body
    parsed = [data.data.map(&.attributes)] of Array(T)

    if (current = data.meta.current_page) < (total = data.meta.total_pages)
      (current+1..total).each do |index|
        results = Crest.get "#{@config.url}/api/application/#{route}?page=#{index}", headers: default_headers
        data = Models::FractalList(T).from_json results.body
        parsed << data.data.map &.attributes
      end
    end

    parsed
  end

  private macro handler(route, type)
    def create_{{ route.id }}(*, exclude : Bool = false, ids : Array(Int32)? = nil,
                              from : Int32? = nil, to : Int32? = nil) : Array(Archive::Source({{ type }}))
      results = get_all_pages {{ route }}, {{ type }}
      sources = [] of Archive::Source({{ type }})

      results.each_with_index do |res, index|
        sources << Archive::Source({{ type }}).new index, res
      end

      sources
    end
  end

  handler "users", Models::User
end
