# Several sentences don't have a Loc/Id in our database. This shall fix it.
class CreateMissingLocids < MigrationWithData
  def up
    Sentence.where(locid: nil).find_each do |sentence|
      onto_locid = Ontology.where(id: sentence.ontology.id).pluck(:locid).first
      sentence_name = select_attributes(sentence, :name)[:name]
      sep = '//'
      sentence_locid = "#{onto_locid}#{sep}#{sentence_name}"
      update_columns(sentence, locid: sentence_locid)
    end
  end

  def down
    # Nothing to do because missing data was generated.
  end
end
