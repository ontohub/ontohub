# Base controller for all API controllers
class Api::V1::Base < ApplicationController
  respond_to :json

  protected
  def check_write_permission
    authorize! :write, resource
  end
end
