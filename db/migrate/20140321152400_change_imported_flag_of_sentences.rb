class ChangeImportedFlagOfSentences < ActiveRecord::Migration
  def change
    change_column :sentences, :imported, :boolean, default: false
  end
end
