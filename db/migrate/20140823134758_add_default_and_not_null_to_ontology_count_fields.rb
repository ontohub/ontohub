class AddDefaultAndNotNullToOntologyCountFields < ActiveRecord::Migration
  def change
    change_column(:ontologies, :entities_count, :integer,
                  default: 0, null: false)
    change_column(:ontologies, :sentences_count, :integer,
                  default: 0, null: false)
  end
end
