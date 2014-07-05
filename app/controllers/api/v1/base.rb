# Base controller for all API controllers
class Api::V1::Base < ApplicationController

  before_filter :authenticate_user!
  respond_to :json
  helper_method :inherited_collection

  protected

  # collection is overwritten by RABL
  def inherited_collection
    collection
  end

  def check_write_permission
    authorize! :write, resource
  end

end
