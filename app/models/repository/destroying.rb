module Repository::Destroying
  extend ActiveSupport::Concern

  # Only use `destroy_asynchronously` if you want to destroy a repository.
  # It prepares the deletion by setting a flag, which enables the deletion
  # of its ontologies.
  def destroy
    Rails.logger.info "Destroy #{self.class} #{self} (id: #{id})"
    super
  rescue StandardError => e
    self.destroying = false
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
    ontologies.map(&:can_be_deleted_with_whole_repository?).all?
  end
end
