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
                    assorted_object_id: object.id,
                    assorted_object_type: object.class).first_or_create
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
      attrs = select_attributes(object, :locid, assorted_object)
      update_attributes!(attrs[assorted_object], locid: attrs[:locid])
    end
  end
end
