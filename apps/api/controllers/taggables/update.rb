module Api
  module Controllers
    module Taggables
      class Update
        include Api::Action

        params do
          required(:tags) { array? { each { str?  }  }  }
        end

        def initialize()
          @repository = TaggableRepository.new
        end

        def call(params)
          halt 400 unless params.valid?

          taggable = @repository.find(params[:id])
          if taggable.nil?
            halt 404
          end

          updated_taggable = @repository.update(taggable.id, {tags: params.get(:tags)})
          self.body = JSON.generate(updated_taggable.to_h)
        end

        def verify_csrf_token?
          false
        end
      end
    end
  end
end