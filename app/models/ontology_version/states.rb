# 
# states:
# * pending
# * downloading
# * processing
# * failed
# * done
# 
module OntologyVersion::States
  extend ActiveSupport::Concern
  
  include StateUpdater
  
  included do
    after_save :update_state_in_ontology, if: :state_changed?
  end
  
  protected
  
  def update_state_in_ontology
    ontology.state = state.to_s
    ontology.save!
  end

end
