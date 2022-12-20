module Fossil
  class Archive
    include JSON::Serializable

    property created_at : Time?
    property files : Array(String)
    @[JSON::Field(ignore: true)]
    property sources : Array(Source)

    def initialize
      @files = [] of String
      @sources = [] of Source
    end

    def save(dir : Path) : Nil
      Dir.mkdir_p dir
      @files = @sources.map &.save dir
      @created_at = Time.utc
      File.write(dir / "archive.lock", to_json)
    end

    struct Source
      include JSON::Serializable

      getter key : String
      getter index : Int32
      getter count : Int32
      getter data : Array(Models::Base)

      def initialize(@key, @index, @data)
        @count = data.size
      end

      def save(dir : Path) : String
        path = dir / "#{@key}_#{@index}.json"
        File.write path, to_json

        path.to_s
      end
    end
  end
end
