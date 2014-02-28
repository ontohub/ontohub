class ChangeTypeOfIriForLogics < ActiveRecord::Migration
  def change
    change_column :logics, :iri, :text
  end
end
