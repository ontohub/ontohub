class ChangeTypeOfIriForLinks < ActiveRecord::Migration
  def change
    change_column :links, :iri, :text
  end
end
