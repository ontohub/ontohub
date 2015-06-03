class RemoveIsAxiomAndIsDefinitionFromSentences < ActiveRecord::Migration
  def change
    remove_column :sentences, :is_axiom
    remove_column :sentences, :is_definition
  end
end
