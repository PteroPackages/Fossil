class Fossil::Handler
  getter config : Config

  def initialize(@config)
  end

  def default_headers : Hash(String, String)
    {
      "User-Agent"    => "Fossil Client v#{VERSION}",
      "Content-Type"  => "application/json",
      "Accept"        => "application/json",
      "Authorization" => "Bearer #{@config.key}",
    }
  end

  private def get_all_pages(path : String, type : T.class) : Array(Array(Models::Base)) forall T
    Log.info "Fetching #{type.name.split("::").last.downcase} objects..."
    results = Crest.get "#{@config.url}/api/application/#{path}", headers: default_headers
    data = Models::FractalList(T).from_json results.body
    Log.info "> #{data.data.size} objects received"

    parsed = [] of Array(Models::Base)
    parsed << data.data.map &.attributes.as(Models::Base)

    if (total = data.meta.pagination.total_pages) > 1
      (2..total).each do |index|
        results = Crest.get "#{@config.url}/api/application/#{path}?page=#{index}", headers: default_headers
        data = Models::FractalList(T).from_json results.body

        Log.info "#{data.data.size} objects received"
        parsed << data.data.map &.attributes.as(Models::Base)
      end
    end

    parsed
  end

  private macro handler(route, type)
    def create_{{ route.id }}(*, exclude : Bool = false, ids : Array(Int32)? = nil,
                              from : Int32? = nil, to : Int32? = nil) : Array(Archive::Source)
      results = get_all_pages {{ route }}, {{ type }}
      sources = [] of Archive::Source

      results.each_with_index do |res, index|
        sources << Archive::Source.new {{ route }}, index, res
      end

      sources
    end
  end

  handler "users", Models::User
  handler "servers", Models::Server
  handler "nodes", Models::Node
  handler "nests", Models::Nest
end
