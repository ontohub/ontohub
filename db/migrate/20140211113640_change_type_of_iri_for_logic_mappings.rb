class ChangeTypeOfIriForLogicMappings < ActiveRecord::Migration
  def change
    change_column :logic_mappings, :iri, :text
  end
end
