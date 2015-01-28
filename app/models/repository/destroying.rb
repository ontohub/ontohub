module Repository::Destroying
  extend ActiveSupport::Concern

  included do
    scope :destroying, ->() { unscoped.where(is_destroying: true) }
    scope :active, ->() { where(is_destroying: false) }
    default_scope ->() { active }
  end

  # Only use `destroy_asynchronously` if you want to destroy a repository.
  # It prepares the deletion by setting a flag, which enables the deletion
  # of its ontologies.
  def destroy
    Rails.logger.info "Destroy #{self.class} #{self} (id: #{id})"
    super
  rescue StandardError => e
    self.is_destroying = false
    save!
    raise e.class, I18n.t('repository.delete_error', oms: Settings.OMS.with_indefinite_article)
  end

  def destroy_asynchronously
    unless can_be_deleted?
      raise Repository::DeleteError, I18n.t('repository.delete_error')
    end
    Rails.logger.info "Mark #{self.class} #{self} (id: #{id}) as is_destroying"
    self.is_destroying = true
    save!
    async(:destroy)
  end

  def can_be_deleted?
    ontologies.all?(&:can_be_deleted_with_whole_repository?)
  end
end
