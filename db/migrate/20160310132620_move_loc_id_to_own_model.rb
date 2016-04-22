class MoveLocIdToOwnModel < MigrationWithData
  def up
    klasses = [Mapping,
               OntologyMember::Symbol,
               Ontology,
               ProofAttempt,
               ProverOutput,
               Sentence,
              ]
    klasses.each do |klass|
      klass.find_each do |object|
        attrs = select_attributes(object, :locid)
        LocId.where(locid: attrs[:locid],
                    specific_id: object.id,
                    specific_type: object.class.to_s).first_or_create
      end
    end
    %i( mappings
        symbols
        ontologies
        proof_attempts
        prover_outputs
        sentences
      ).each do |table|
        remove_columns table, :locid
      end
  end

  def down
    %i( mappings
        symbols
        ontologies
        proof_attempts
        prover_outputs
        sentences
      ).each do |table|
        add_column table, :locid
      end
    LocId.find_each do |object|
      attrs = select_attributes(object, :locid, :specific_id, :specific_type)
      specific = attrs[:specific_type].constantize.find(attrs[:specific_id])
      update_attributes!(specific, locid: attrs[:locid])
    end
  end
end
