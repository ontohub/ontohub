class ChangeTypeOfIriForLanguageAdjoints < ActiveRecord::Migration
  def change
    change_column :language_adjoints, :iri, :text
  end
end
