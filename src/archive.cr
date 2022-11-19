module Fossil
  class Archive
    include JSON::Serializable

    property created_at : Time?
    property files : Array(String)
    @[JSON::Field(ignore: true)]
    property sources : Array(Source(JSON::Serializable))

    def initialize
      @files = [] of String
      @sources = [] of Source(JSON::Serializable)
    end

    def save(dir : Path) : Nil
      @files = @sources.map &.save dir

      File.open(dir / "archive.lock") do |file|
        @created_at = Time.utc
        to_json file
      end
    end

    struct Source(M)
      include JSON::Serializable

      getter index : Int32
      getter count : Int32
      getter data : Array(M)

      def initialize(@index, @data)
        @count = data.size
      end

      def save(dir : Path) : String
        path = dir / "#{M.class.name.downcase}_#{@index}.json"

        File.open(path) do |file|
          to_json file
        end

        path.to_s
      end
    end
  end
end
