module Fossil
  class Archive
    property sources : Array(Source)

    def initialize
      @sources = [] of Source
    end

    def generate(dir : Path) : Nil
    end

    struct Source(M)
      getter key : String
      getter data : Array(M)

      def initialize(@data : Array(M))
        @key = M.class.name.downcase
      end
    end
  end
end
