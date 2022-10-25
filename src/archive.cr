module Fossil
  class Archive
    include JSON::Serializable

    getter scopes : Array(String)
    getter sourcemap : Hash(String, Array(String))
    @[JSON::Field(ignore: true)]
    getter sources : Array(Source(Models::BaseModel))

    def initialize(@scopes, @sourcemap)
      @sources = [] of Source(Models::BaseModel)
    end

    def self.create
      new Array(String).new, Hash(String, Array(String)).new
    end

    def generate(path : Path) : Nil
      if users = @sources.find { |s| s.key == "user" }
        File.open(path / "frag_user_1.json") do |file|
          IO.copy users.to_json, file
        end
      end
    end

    struct Source(M)
      getter key : String
      property meta : Hash(String, JSON::Any::Type)
      property data : Array(M)

      def initialize
        @key = M.class.name.downcase
        @meta = {} of String => JSON::Any::Type
        @data = [] of M
      end
    end
  end
end
