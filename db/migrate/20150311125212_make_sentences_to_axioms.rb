class MakeSentencesToAxioms < MigrationWithData
  def up
    Sentence.unscoped.where(type: nil).find_each do |sentence|
      update_attributes!(sentence, type: 'Axiom')
    end
  end

  def down
    Sentence.unscoped.where(type: 'Axiom').find_each do |sentence|
      update_attributes!(sentence, type: nil)
    end
  end
end
