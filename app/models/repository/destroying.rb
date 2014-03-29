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
    raise e.class, "Can't delete repository: It contains an ontology that is imported by another repository."
  end

  protected

  def mark_as_destroying
    self.class.instance_variable_get(:@destroying) << self.id if self.id
  end

  def unmark_as_destroying
    self.class.instance_variable_get(:@destroying).delete(self.id) if self.id
  end
end
