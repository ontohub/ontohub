class CreateEntitiesOopsResponses < ActiveRecord::Migration
  def change
    create_table :entities_oops_responses do |t|
      t.references :oops_response, null: false
      t.references :entity, null: false
    end

    change_table :entities_oops_responses do |t|
      t.index [:oops_response_id, :entity_id]
      t.foreign_key :oops_responses, dependent: :delete
      t.foreign_key :entities
    end
  end
end
