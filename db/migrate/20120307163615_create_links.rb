class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.references :source, :null => false
      t.references :target, :null => false
      t.references :logic_mapping # for heterogeneous links. nil means identity = homogeneous link
      t.string :kind # roughly corresponds to DGLinkType constructor and LinkKind in Hets
      t.boolean :theorem, :default => false # definition or theorem link?
      t.boolean :local, :default => false # local or global link? corresponds to Scope in Hets. Local links may arise in development graph proofs
      t.boolean :auxiliary, :default => false # true for component signature morphisms which are coded as links here, 
            # see FreeOrCofreeDefLink (here the link is the inclusion of the intermediate node into the source) or HidingFreeOrCofreeThm in Hets
      t.timestamps :null => false
    end

    change_table :links do |t|
      t.index :source_id
      t.index :target_id
      t.foreign_key :ontologies, :column => :source_id
      t.foreign_key :ontologies, :column => :target_id
    end
  end
end
