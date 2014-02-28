module PermissionHelper

  def can_write?(parent, cls_sym)
    cls = cls_sym.to_s.classify.constantize
    if parent
      can?(:write, cls) && can?(:write, parent.repository)
    else
      can? :write, cls
    end
  end

end
