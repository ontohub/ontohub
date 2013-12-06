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
    after_save :after_update_state, if: :state_changed?
  end
  
  protected
  
  def after_update_state
    ontology.state = state.to_s
    ontology.save!
    if ontology.distributed?
      ontology.children.update_all state: ontology.state
    end
  end

end
