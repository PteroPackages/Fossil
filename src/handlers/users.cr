module Fossil::Handlers
  class UserHandler < BaseHandler
    def create(*, exclude : Bool = false, ids : Array(Int32)? = nil,
               from : Int32? = nil, to : Int32? = nil) : Array(Archive::Source(Models::User))
      Log.info "Fetching user data..."
      sources = [] of Archive::Source(Models::User)

      get_all_users do |users|
        sources << Archive::Source.new users
      end

      sources
    end

    def restore : Nil
    end

    private def get_all_users(page : Int32 = 1, &block : -> Array(Models::User)) : Nil
      res = Crest.get route("application/users?page=#{page}"), headers: get_headers
      data = Models::FractalList(Models::User).from_json res.body

      block.call data.data.map &.attributes

      if data.meta.current_page < data.meta.total_pages
        get_all_users(page + 1, &block)
      end
    # TODO: handle ratelimits
    # rescue Crest::TooManyRequests
    end
  end
end
