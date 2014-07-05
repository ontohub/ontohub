# Base controller for all API controllers
class Api::V1::RepositoriesController < Api::V1::Base

  inherit_resources
  actions :index, :update
  before_filter :check_write_permission, :except => [:index, :show]
  has_scope :path

  def index
    collection
    render :index
  end

end
