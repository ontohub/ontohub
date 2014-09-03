module Repository::Destroying
  extend ActiveSupport::Concern

  included do
    @destroying ||= []
    before_destroy :mark_as_destroying, prepend: true
  end

  def is_destroying?
    self.class.instance_variable_get(:@destroying).include?(self.id)
  end

  def destroy
    super
  rescue StandardError => e
    unmark_as_destroying
    raise e.class, I18n.t('repository.delete_error', oms: Settings.OMS.with_indefinite_article)
  end

  def destroy_asynchonously
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
