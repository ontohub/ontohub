# Base controller for all API controllers
class Api::V1::Base < ApplicationController
  API_KEY_HEADER = 'Ontohub-API-Key'
  API_KEY_SYMBOL = :api_key

  respond_to :json

  protected
  def check_write_permission
    authorize! :write, resource
  end

  def current_user
    ApiKey.valid.where(key: api_key).first.try(:user) if api_key
  end

  def api_key
    @api_key_in_request ||=
      if params[API_KEY_SYMBOL].present?
        params[API_KEY_SYMBOL]
      elsif request.headers[API_KEY_HEADER].present?
        request.headers[API_KEY_HEADER]
      end
  end
end
