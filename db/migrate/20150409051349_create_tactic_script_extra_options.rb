class CreateTacticScriptExtraOptions < ActiveRecord::Migration
  def change
    create_table :tactic_script_extra_options do |t|
      t.references :tactic_script, index: true, null: false
      t.text :option, null: false
      t.timestamps
    end
  end
end
