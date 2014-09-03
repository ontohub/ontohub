module Repository::Destroying
  extend ActiveSupport::Concern

  included do
    scope :destroying, where(destroying: true)
    scope :active, where(destroying: false)
  end

  def destroy
    Rails.logger.info "Destroy #{self.class} #{self} (id: #{id})"
    super
  rescue StandardError => e
    raise e.class, I18n.t('repository.delete_error', oms: Settings.OMS)
  end

  def destroy_asynchonously
    Rails.logger.info "Mark #{self.class} #{self} (id: #{id}) as destroying"
    self.destroying = true
    save!
    async(:destroy)
  end

  def can_be_deleted?
    ontologies.map(&:can_be_deleted_with_whole_repository?).all?
  end
end
