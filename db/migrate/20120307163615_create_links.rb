class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :iri, :null => false
      t.references :ontology, :null => false
      t.references :source, :null => false
      t.references :target, :null => false
      t.references :logic_mapping # for heterogeneous links. nil means identity = homogeneous link
      t.string :kind # roughly corresponds to DGLinkType constructor and LinkKind in Hets
      t.boolean :theorem, :default => false # definition or theorem link?
      t.boolean :proven, :default => false # has the link been proven (makes only sense for theorem links)
      t.boolean :local, :default => false # local or global link? corresponds to Scope in Hets. Local links may arise in development graph proofs
      t.boolean :inclusion, :default => true # is the linka signature inclusion?
      t.references :parent, :default => nil # non-nil for component signature morphisms which are coded as links here,
            # see FreeOrCofreeDefLink (here the link is the inclusion of the intermediate node into the source) or HidingFreeOrCofreeThm in Hets
      t.timestamps :null => false
    end

    change_table :links do |t|
      t.index :ontology_id
      t.index :source_id
      t.index :target_id
      t.foreign_key :ontologies, :dependent => :delete
      t.foreign_key :ontologies, :column => :source_id
      t.foreign_key :ontologies, :column => :target_id
      t.foreign_key :links, :column => :parent_id
    end
  end
end
