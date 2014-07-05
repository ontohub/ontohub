module PermissionHelper

  def can_create?(parent, cls_sym)
    cls = cls_sym.to_s.classify.constantize
    if parent
      can?(:create, cls) && can?(:write, parent.repository)
    else
      can? :create, cls
    end
  end

end
