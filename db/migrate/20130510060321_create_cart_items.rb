class CreateCartItems < ActiveRecord::Migration
  def up
    create_table :cart_items do |t|
      t.references :cart, :null => false
      t.references :ontology_version, :null => false

      t.timestamps :null => false
    end
    change_table :cart_items do |t|
      t.index :cart_id
      t.index :ontology_version_id, :unique => true
      t.foreign_key :carts
    end
  end

end
