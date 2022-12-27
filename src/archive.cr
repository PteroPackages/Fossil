module Fossil
  class Archive
    include JSON::Serializable

    property created_at : Time?
    property files : Array(String)
    @[JSON::Field(ignore: true)]
    property sources : Array(Source) = [] of Source

    def initialize
      @files = [] of String
      @sources = [] of Source
    end

    def compress(dest : Compress::Gzip::Writer) : Nil
      Crystar::Writer.open(dest) do |tar|
        @sources.each do |source|
          @files << source.to_s
          buf = IO::Memory.new
          source.to_json buf

          tar.write_header Crystar::Header.new(name: source.to_s, mode: 0o644, size: buf.size)
          tar.write buf.to_slice
        end

        @created_at = Time.utc
        buf = IO::Memory.new
        to_json buf

        tar.write_header Crystar::Header.new(name: "archive.lock", mode: 0o644, size: buf.size)
        tar.write buf.to_slice
      end
    end

    def save(dir : Path) : Nil
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

      def to_s : String
        "#{@key}_#{@index}.json"
      end

      def save(dir : Path) : String
        path = dir / "#{@key}_#{@index}.json"
        File.write path, to_json

        path.to_s
      end
    end
  end
end
