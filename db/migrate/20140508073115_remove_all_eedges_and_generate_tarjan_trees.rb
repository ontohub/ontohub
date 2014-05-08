class RemoveAllEedgesAndGenerateTarjanTrees < ActiveRecord::Migration
  def change
    EEdge.destroy_all
    
    Rake::Task['generate:owl_ontology_class_hierarchies'].invoke
  end
end
