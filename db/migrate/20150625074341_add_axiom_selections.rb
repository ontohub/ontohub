class AddAxiomSelections < MigrationWithData
  def up
    # model: AxiomSelection
    create_table :axiom_selections, as_relation_superclass: true
    add_column :proof_attempt_configurations, :axiom_selection_id, :integer

    # model: ManualAxiomSelection
    create_table :manual_axiom_selections

    # has_and_belongs_to_many: Axiom/AxiomSelection
    create_table :axioms_axiom_selections, id: false do |t|
      t.integer :sentence_id
      t.integer :axiom_selection_id
    end
    add_index :axioms_axiom_selections, :sentence_id
    add_index :axioms_axiom_selections, :axiom_selection_id,
              # We need to supply a custom name because the generated name is
              # too long for PostgreSQL
              name: 'index_axioms_on_axiom_selection_id'
    add_index :axioms_axiom_selections, [:sentence_id, :axiom_selection_id],
              unique: true, name: 'index_axioms_axiom_selection_unique'

    up_migrate_association_data

    # this has been replaced by the Axioms/AxiomSelection association
    drop_table :axioms_proof_attempt_configurations
    change_column :proof_attempt_configurations, :axiom_selection_id, :integer,
                  null: false
  end

  def down
    create_table :axioms_proof_attempt_configurations, id: false do |t|
      t.integer :sentence_id
      t.integer :proof_attempt_configuration_id
    end
    add_index :axioms_proof_attempt_configurations, :sentence_id
    add_index :axioms_proof_attempt_configurations, :proof_attempt_configuration_id,
              # We need to supply a custom name because the generated name is
              # too long for PostgreSQL
              name: 'index_axioms_pacs_on_proof_attempt_configuration_id'

    down_migrate_association_data

    delete_column :proof_attempt_configurations, :axiom_selection_id, :integer
    drop_table :axioms_axiom_selections
    drop_table :manual_axiom_selections
    drop_table :axiom_selections
  end

  protected

  def up_migrate_association_data
    # migrate axiom selections
    # from ProofAttemptConfiguration to ManualAxiomSelection
    select_association('axioms_proof_attempt_configurations',
                       :proof_attempt_configuration_id,
                       :sentence_id).
      each do |pac_id, column_data|
        mas = ManualAxiomSelection.create!({proof_attempt_configuration_id: pac_id},
                                           without_protection: true)
        pac = ProofAttemptConfiguration.find(pac_id)
        update_columns(pac, axiom_selection_id: mas.axiom_selection.id)
        column_data.map(&:last).each do |axiom_id|
          insert_association('axioms_axiom_selections',
                             axiom_selection_id: mas.axiom_selection.id,
                             sentence_id: axiom_id)
        end
      end
  end

  def down_migrate_association_data
    # migrate axiom selections
    # from ManualAxiomSelection to ProofAttemptConfiguration
    select_association('axioms_axiom_selections',
                       :axiom_selection_id,
                       :sentence_id).
      each do |as_id, column_data|
        as = AxiomSelection.find(as_id)
        pac = ProofAttemptConfiguration.find(as.proof_attempt_configuration_id)
        column_data.map(&:last).each do |axiom_id|
          insert_association('axioms_proof_attempt_configurations',
                             proof_attempt_configuration_id: pac.id,
                             sentence_id: axiom_id)
        end
      end
  end

  def select_association(table, column_a, column_b)
    query = %(SELECT * FROM "#{table}" ORDER BY "#{column_a}" ASC;)
    pluck_select(query, column_a, column_b).group_by { |a, _b| a }
  end

  def insert_association(table, values_hash)
    query = <<-SQL
      INSERT INTO "#{table}"
      (#{values_hash.keys.join(', ')})
      VALUES (#{values_hash.values.join(', ')});
    SQL
    sql.insert(sanitize(query))
  end
end
