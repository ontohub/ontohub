class CreateTacticScripts < ActiveRecord::Migration
  def change
    create_table :tactic_scripts do |t|
      t.string :script

      t.references :proof_status, null: false

      t.timestamps
    end
  end
end
