module SharedHelper
  def user_has_deleted_repositories?
    current_user.owned_deleted_repositories.present?
  end
end
