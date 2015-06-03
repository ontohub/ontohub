class AddTypeToSentences < ActiveRecord::Migration
  def change
    add_column :sentences, :type, :string
  end
end
