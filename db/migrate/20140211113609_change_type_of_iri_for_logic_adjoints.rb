class ChangeTypeOfIriForLogicAdjoints < ActiveRecord::Migration
  def change
    change_column :logic_adjoints, :iri, :text
  end
end
