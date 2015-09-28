class AddFinishedAttributeToAxiomSelections < MigrationWithData
  def change
    add_column :axiom_selections, :finished, :boolean, default: false
  end
end
