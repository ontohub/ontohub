class SshAccessController < InheritedResources::Base

  def index
    allowed = false
    render json: {allowed: allowed}
  end

end
