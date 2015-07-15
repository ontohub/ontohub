class RemoveNumberAndLocidFromProofAttemptConfiguration < MigrationWithData
  def generate_number(ontology_id)
    max = ProofAttemptConfiguration.
      where(ontology_id: ontology_id).maximum('number').to_i
    max + 1
  end

  def up
    remove_column :proof_attempt_configurations, :number
    remove_column :proof_attempt_configurations, :locid
  end

  def down
    add_column :proof_attempt_configurations, :number, :integer
    add_column :proof_attempt_configurations, :locid, :text

    ProofAttemptConfiguration.find_each do |pac|
      pac_attrs = select_attributes(pac, :ontology_id)

      number = generate_number(pac_attrs[:ontology_id])

      ontology = Ontology.find(pac_attrs[:ontology_id])
      onto_attrs = select_attributes(ontology, :locid)
      locid = "#{onto_attrs[:locid]}//proof-attempt-configuration-#{number}"

      update_attributes!(pac, number: number, locid: locid)
    end
  end
end
