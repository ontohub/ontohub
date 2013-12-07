class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :ontology
      t.text :text

      t.timestamps
    end
    add_index :reviews, :ontology_id
  end
end
