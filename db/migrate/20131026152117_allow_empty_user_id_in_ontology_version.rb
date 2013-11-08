class AllowEmptyUserIdInOntologyVersion < ActiveRecord::Migration
  def change
    change_column :ontology_versions, :user_id, :integer, null: true
  end
end
