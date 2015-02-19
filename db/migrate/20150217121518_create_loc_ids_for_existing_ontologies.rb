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
        portion = symbol.name
        portion = portion[0..-2] if portion.end_with?('>')
        portion = portion.split('#', 2).last
        symbol.update_column(:locid, "#{ontology.locid}//#{portion}")
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
