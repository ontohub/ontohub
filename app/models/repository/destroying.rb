module Repository::Destroying
  extend ActiveSupport::Concern

  DELETION_WAIT_TIME = 30.days

  included do
    scope :destroying, ->() { unscoped.where(is_destroying: true) }
    scope :active, ->() { where(is_destroying: false) }
    default_scope ->() { active }

    def self.find_deleted_repository_with_owner(path, user)
      repository = Repository.unscoped.find_by_path(path)
      if user.owned_ids('Repository').include?(repository.id)
        repository
      end
    end
  end

  # Only use `destroy_asynchronously` if you want to destroy a repository.
  # It prepares the deletion by setting a flag, which enables the deletion
  # of its ontologies.
  def destroy
    Rails.logger.info("Destroy #{self.class} #{self} (id: #{id})")
    super
  rescue StandardError => e
    self.is_destroying = false
    save!
    raise e.class,
          I18n.t('repository.delete_error', oms: Settings.OMS.with_indefinite_article),
          cause: e
  end

  def destroy_asynchronously
    unless can_be_deleted?
      raise Repository::DeleteError, I18n.t('repository.delete_error')
    end
    Rails.logger.info("Mark #{self.class} #{self} (id: #{id}) as is_destroying")
    self.is_destroying = true
    save!
    RepositoryDeletionWorker.perform_in(DELETION_WAIT_TIME, id)
  end

  def can_be_deleted?
    ontologies.all?(&:can_be_deleted_with_whole_repository?)
  end
end
