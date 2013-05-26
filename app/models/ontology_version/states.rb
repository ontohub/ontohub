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
    if ontology.distributed?
      # can't  work on ontology.children directly due to acts_as_tree
      children = Ontology.where :parent_id => ontology.id
      children.each{|c| c.state = state.to_s; c.save}
    end
  end

end
