class SshAccessController < InheritedResources::Base

  MIRROR_DENY_MSG = "you cannot write to a mirror repository, they are readonly"

  belongs_to :repository, finder: :find_by_path!

  def index
    allowed = SshAccess.determine_permission(
      *SshAccess.extract_permission_params(params, parent), parent)
    render json: {allowed: allowed}
  rescue SshAccess::InvalidAccessOnMirrorError
    render json: {allowed: false,
                  reason: MIRROR_DENY_MSG,
                  provide_to_user: true}
  rescue => e# ensure that we always return a valid response
    render json: {allowed: false,
                  reason: "internal server problem: #{e.message}",
                  provide_to_user: false}
  end

end
