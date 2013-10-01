class RepositoriesController < ApplicationController

  inherit_resources
  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index, :show]

end
