module PermissionHelper

  def can_add?(parent, cls)
    if parent
      can?(:write, cls) && can?(:write, parent.repository)
    else
      can? :write, cls
    end
  end

end
