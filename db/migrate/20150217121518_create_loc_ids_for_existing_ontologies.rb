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

      ontology.symbols.find_each do |symbol|
        symbol.update_column(:locid, "#{ontology.locid}//#{symbol.name}")
      end

      ontology.mappings.find_each do |mapping|
        mapping.update_column(:locid, "#{ontology.locid}//#{mapping.name}")
      end

      ontology.sentences.find_each do |sentence|
        sentence.update_column(:locid, "#{ontology.locid}//#{sentence.name}")
      end
    end
  end

  def down
    Ontology.find_each do |ontology|
      ontology.locid = nil
      ontology.save!
    end
  end
end
