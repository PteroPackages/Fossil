module Fossil::Handlers
  class UserHandler < BaseHandler
    def create(*, exclude : Bool = false, ids : Array(Int32)? = nil,
               from : Int32? = nil, to : Int32? = nil) : Archive::Source(Models::User)
      Log.info "Fetching user data..."
      users = get_user_list.data.map &.attributes

      Log.info "Saving user data to source..."
      source = Archive::Source(Models::User).new
      source.data = users
      source.meta["ids"] = users.map(&.id)

      source
    end

    def restore : Nil
    end

    private def get_user_list : Models::FractalList(Models::User)
      res = Crest.get route("application/users"), headers: get_headers

      Models::FractalList(Models::User).from_json res.body
    end
  end
end
