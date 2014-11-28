class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.string :token, unique: true
      t.references :repository, null: false
      t.datetime :expiration

      t.timestamps
    end

    change_table :access_tokens do |t|
      t.foreign_key :repositories
      t.index :token
    end
  end
end
