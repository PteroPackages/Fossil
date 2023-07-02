module Fossil
  class Archive
    include JSON::Serializable

    struct Source
      include JSON::Serializable

      getter id : String
      getter scope : String
      getter index : Int32
      getter count : Int32
      getter data : Array(JSON::Any)

      def initialize(@id, @scope, @index, @data)
        @count = data.size
      end

      def to_s : String
        "#{@id}-#{@scope}-#{@index}.json"
      end
    end

    property timestamp : Int32
    property files : Array(String)
    property scopes : Array(String)
    @[JSON::Field(ignore: true)]
    property sources : Array(Source)

    def initialize(@scopes)
      @timestamp = 0
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

        @timestamp = Time.utc.to_unix
        buf = IO::Memory.new
        to_json buf

        # TODO: maybe change header name
        tar.write_header Crystar::Header.new(name: "archive.lock", mode: 0o644, size: buf.size)
        tar.write buf.to_slice
      end
    end
  end
end
