class ChangeTypeOfIriForLanguageMappings < ActiveRecord::Migration
  def change
    change_column :language_mappings, :iri, :text
  end
end
