class MakeSentencesToAxioms < MigrationWithData
  def up
    Sentence.unscoped.where(type: nil).select(:id).find_each do |sentence|
      update_attributes!(sentence, type: 'Axiom')
    end
  end

  def down
    Sentence.unscoped.where(type: 'Axiom').select(:id).find_each do |sentence|
      update_attributes!(sentence, type: nil)
    end
  end
end
