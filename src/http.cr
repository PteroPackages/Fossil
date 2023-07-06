module Fossil::HTTP
  extend self

  DEFAULT_HEADERS = {
    "User-Agent"   => "Fossil Client v#{VERSION}",
    "Content-Type" => "application/json",
    "Accept"       => "application/json",
  }

  def test_connection : Nil
    Crest.get "#{Config.url}/sanctum/csrf-cookie"

    DEFAULT_HEADERS["Authorization"] = "Bearer #{Config.key}"
  end

  private def get_all_pages(path : String) : Array(JSON::Any)
    response = Crest.get "#{Config.url}/api/application#{path}", headers: DEFAULT_HEADERS
    data = JSON.parse response.body

    results = [data]
    if (total = data["meta"]["pagination"]["total_pages"].as_i) > 1
      progress = Progress.new total

      (2..total).each do |index|
        response = Crest.get "#{Config.url}/api/application#{path}?page=#{index}", headers: DEFAULT_HEADERS
        data = JSON.parse response.body
        results << data
        progress.tick
      end

      progress.done
    end

    results
  end

  private macro def_source(name, route)
    def create_{{name}}_source(id : String) : Array(Archive::Source)
      results = get_all_pages {{ route }}
      sources = [] of Archive::Source

      results.each_with_index do |result, index|
        sources << Archive::Source.new(id, {{ name.stringify }}, index, result["data"].as_a)
      end

      sources
    end
  end

  def_source users, "/users"
  def_source servers, "/servers"
  def_source nodes, "/nodes"
  def_source nests, "/nests"
end
