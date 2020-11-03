module Api
  module Controllers
    module Spotify
      class GetPlaylists
        include Api::Action

        def initialize
          RSpotify.raw_response = true
          @taggables = TaggableRepository.new
        end

        def call(params)
          page = 0
          if params[:page] && params[:page].to_i > 0
            page = params[:page].to_i - 1
          end
          grouped_taggables = @taggables
            .find_by_user_id(current_user.id)
            .group_by {|t| t.ext_id}

          begin
            response = @spotify_user.playlists(limit: 50, offset: 50 * page)
          rescue RestClient::Unauthorized
            # There is a uncatched bug here - this could also be because a token needs to be refreshed
            # OR most probably WAS refreshed but not saved to the db?
            halt 401
          end
          playlists = JSON.parse(response.body)

          for p in playlists["items"] do
            if grouped_taggables[p["id"]]
              p[:tags] = grouped_taggables[p["id"]][0].tags
              p[:taggable_id] = grouped_taggables[p["id"]][0].id
            else
              p[:tags] = []
            end
          end

          self.body = {items: playlists["items"], total: playlists["total"]}.to_json
        end
      end
    end
  end
end
