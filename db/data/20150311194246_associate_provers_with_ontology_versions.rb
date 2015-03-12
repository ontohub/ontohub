class AssociateProversWithOntologyVersions < ActiveRecord::Migration
  def self.up
    OntologyVersion.find_each(&:retrieve_available_provers)
  end

  def self.down
    OntologyVersion.find_each do |ontology_version|
      ontology_version.provers = []
      ontology_version.save!
    end
  end
end
