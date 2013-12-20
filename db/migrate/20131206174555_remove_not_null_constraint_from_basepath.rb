class RemoveNotNullConstraintFromBasepath < ActiveRecord::Migration
  def change
    change_column :ontologies, :basepath, :string, :null => true
  end
end
