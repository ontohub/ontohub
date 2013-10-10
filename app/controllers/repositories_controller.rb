class RepositoriesController < ApplicationController

  inherit_resources
  defaults finder: :find_by_path!
  custom_actions collection: :import

  load_and_authorize_resource :except => [:index, :show]

  def index
    @content_kind = :repositories
  end

  def show
    @content_kind = :repositories
  end

  def create
    if Repository::SOURCE_TYPES.include?(params[:source_type])
      if r = Repository.import_remote(params[:source_type], current_user, params[:source_address], params[:name])
        redirect_to r
      end
    else
      super
    end
  end
end
