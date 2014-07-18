module PermissionHelper

  def permission_modal_body(permission)
    modal_body(t("permission.delete_header"), t("permission.delete_desc", role: permission.role, subject: permission.subject, class: permission.item.class, item: permission.item), [permission.item, permission], t('permission.delete_btn'), modal_id: "role_modal_#{permission.id}")
  end

  def can_create?(parent, cls_sym)
    cls = cls_sym.to_s.classify.constantize
    if parent
      can?(:create, cls) && can?(:write, parent.repository)
    else
      can? :create, cls
    end
  end

end
