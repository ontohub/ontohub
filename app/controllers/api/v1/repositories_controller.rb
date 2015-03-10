class Api::V1::RepositoriesController < Api::V1::Base
  inherit_resources
  defaults finder: :find_by_path!

  actions :show
end
