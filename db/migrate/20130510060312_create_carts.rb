class CreateCarts < ActiveRecord::Migration
  def up
    create_table :carts do |t|
      t.text :dol_command

      t.timestamps :null => false
    end
    
  end

end
