class AddLocIdToSentences < ActiveRecord::Migration
  def change
    add_column :sentences, :locid, :text
  end
end
