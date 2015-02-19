class CreateLocIdsForExistingOntologies < ActiveRecord::Migration
  def up
    Ontology.all.each do |ontology|
      ontology.locid = "/#{ontology.repository.path}/"
      if ontology.parent
        ontology.locid << "#{ontology.parent.basepath}//#{ontology.name}"
      else
        ontology.locid << "#{ontology.basepath}"
      end
      ontology.update_column(:locid, ontology.locid)
    end
  end

  def down
    Ontology.find_each do |ontology|
      ontology.locid = nil
      ontology.save!
    end
  end
end
