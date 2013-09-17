class AddAcronymDocumentationToOntologies < ActiveRecord::Migration
  def change
    change_table :ontologies do |t|
    t.string :acronym
    t.string :documentation
    end
  end
end
