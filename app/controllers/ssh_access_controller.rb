class SshAccessController < InheritedResources::Base

  belongs_to :repository, finder: :find_by_path!

  def index
    allowed = SshAccess.determine_permission(
      *SshAccess.extract_permission_params(params, parent))
    render json: {allowed: allowed}
  end

end
