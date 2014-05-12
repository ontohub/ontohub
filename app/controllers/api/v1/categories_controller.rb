class Api::V1::CategoriesController < Api::V1::Base

  inherit_resources
  actions :index

  def index
    collection
    render :index
  end

end
