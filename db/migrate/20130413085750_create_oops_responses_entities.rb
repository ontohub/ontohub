class CreateOopsResponsesEntities < ActiveRecord::Migration
  def change
    create_table :oops_responses_entities do |t|
      t.references :oops_response, null: false
      t.references :entity, null: false
    end

    change_table :oops_responses_entities do |t|
      t.index [:oops_response_id, :entity_id]
      t.foreign_key :oops_responses, dependent: :delete
      t.foreign_key :entities
    end
  end
end
