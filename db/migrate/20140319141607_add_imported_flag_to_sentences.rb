class AddImportedFlagToSentences < ActiveRecord::Migration
  def change
    add_column :sentences, :imported, :boolean, default: true
  end
end
