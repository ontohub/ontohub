class CreateGeneratedAxioms < ActiveRecord::Migration
  def change
    create_table :generated_axioms do |t|
      t.string :name, null: false
      t.references :proof_attempt, null: false
    end

    add_index :generated_axioms, :name
  end
end
