class RepositoriesController < ApplicationController

  inherit_resources
  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index, :show]

  def index
    @content_kind = :repositories
  end

  def show
    @content_kind = :repositories
  end

  def create
    resource.user = current_user
    super
  end
end
