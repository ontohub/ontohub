class CreateTacticScripts < ActiveRecord::Migration
  def change
    create_table :tactic_scripts do |t|
      t.references :proof_attempt, null: false
      t.integer :time_limit
      t.timestamps
    end
  end
end
