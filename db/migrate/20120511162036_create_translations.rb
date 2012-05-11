class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|

      t.timestamps
    end
  end
end
