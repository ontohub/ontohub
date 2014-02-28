class ChangeTypeOfIriForLanguages < ActiveRecord::Migration
  def change
    change_column :languages, :iri, :text
  end
end
