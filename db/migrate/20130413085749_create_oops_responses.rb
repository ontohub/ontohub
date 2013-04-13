class CreateOopsResponses < ActiveRecord::Migration
  def change
    create_table :oops_responses do |t|
      t.references :oops_request, null: false
      t.integer :code
      t.string :name, null: false
      t.string :description
      t.string :type, null: false

      t.timestamps null: false
    end

    change_table :oops_responses do |t|
      t.index :oops_request_id
    end
  end
end
