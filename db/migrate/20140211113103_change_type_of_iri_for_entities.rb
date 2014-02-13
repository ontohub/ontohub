class ChangeTypeOfIriForEntities < ActiveRecord::Migration
  def change
    change_column :entities, :iri, :text
  end
end
