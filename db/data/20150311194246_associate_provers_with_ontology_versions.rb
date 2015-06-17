class AssociateProversWithOntologyVersions < ActiveRecord::Migration
  def self.up
    OntologyVersion.find_each do |ontology_version|
      retry_provers_retrieval(ontology_version, 3)
    end
  end

  def self.down
    OntologyVersion.find_each do |ontology_version|
      ontology_version.provers = []
      ontology_version.save!
    end
  end

  protected

  def self.retry_provers_retrieval(ontology_version, max_attempts)
    begin
      ontology_version.retrieve_available_provers
    rescue Net::ReadTimeout
      if max_attempts > 0
        puts "Timeout, trying again: OntologyVersion #{ontology_version.id}"
        retry_provers_retrieval(ontology_version, max_attempts - 1)
      else
        puts "Timeout, limit reached: OntologyVersion #{ontology_version.id}"
      end
    rescue ::StandardError => e
      puts "Errored at OntologyVersion #{ontology_version.id}"
    end
  end
end
