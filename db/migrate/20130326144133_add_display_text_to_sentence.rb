class AddDisplayTextToSentence < ActiveRecord::Migration
  def change
    add_column :sentences, :display_text, :text
  end
end
