class Api::V1::ActionsController < Api::V1::Base
  inherit_resources

  actions :show

  def show
    if resource.ready?
      response.status = 303
      response.headers['Location'] = inner_resource_location
      render json: {status: response.message, location: response.location}
    else
      super
    end
  end

  protected
  def inner_resource_location
    if resource.resource.respond_to?(:locid)
      resource.resource.locid
    else
      url_for(resource.resource)
    end
  end
end
