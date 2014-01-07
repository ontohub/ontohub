class ChangeTypeOfIriForAlternativeIris < ActiveRecord::Migration
  def change
    change_column :alternative_iris, :iri, :text
  end
end
