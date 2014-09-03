module Repository::Destroying
  extend ActiveSupport::Concern

  included do
    @destroying ||= []
    before_destroy :mark_as_destroying, prepend: true

    scope :destroying, where(destroying: true)
    scope :active, where(destroying: false)
  end

  def is_destroying?
    self.class.instance_variable_get(:@destroying).include?(self.id)
  end

  def destroy
    Rails.logger.info "Destroy #{self.class} #{self} (id: #{id})"
    super
  rescue StandardError => e
    unmark_as_destroying
    raise e.class, I18n.t('repository.delete_error', oms: Settings.OMS)
  end

  def destroy_asynchonously
    Rails.logger.info "Mark #{self.class} #{self} (id: #{id}) as destroying"
    self.destroying = true
    save!
    async(:destroy)
  end

  def can_be_deleted?
    ontologies.map(&:can_be_deleted?).all?
  end

  protected

  def mark_as_destroying
    self.class.instance_variable_get(:@destroying) << self.id if self.id
  end

  def unmark_as_destroying
    self.class.instance_variable_get(:@destroying).delete(self.id) if self.id
  end
end
