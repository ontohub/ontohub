class CreateCodeReferences < ActiveRecord::Migration
  def change
    create_table :code_references do |t|
      t.integer :begin_line
      t.integer :end_line
      t.integer :begin_column
      t.integer :end_column
      t.references :referencee, polymorphic: true

      t.timestamps
    end
  end
end
