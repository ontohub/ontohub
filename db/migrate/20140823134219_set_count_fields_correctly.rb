class SetCountFieldsCorrectly < ActiveRecord::Migration
  def up
    Ontology.find_each do |ontology|
      ontology.entities_count = ontology.entities.count
      ontology.sentences_count = ontology.sentences.count
      ontology.versions_count = ontology.versions.count
      ontology.metadata_count = ontology.metadata.count
      ontology.comments_count = ontology.comments.count
      ontology.save!
    end
  end

  def down
    # Again, a reversal of this migration does not
    # make a lot of sense, because there is no
    # reason to return to an inconsistent state.
    # Also performing the up-part of the migration
    # does not break anything.
  end
end
