class LinkVersion < ActiveRecord::Base
  belongs_to :link
  belongs_to :source, class_name: 'OntologyVersion'
  belongs_to :target, class_name: 'OntologyVersion'

  attr_accessible :link, :required_cons_status, :proven_cons_status, :proof_status, :source, :target, :source_id, :target_id, :version_number
  before_create :increase_number


private
  def increase_number
    self.version_number = self.link.versions.current ? self.link.versions.current.version_number + 1 : 1
  end

end
