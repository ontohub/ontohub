class MakeSentencesToAxioms < ActiveRecord::Migration
  def self.up
    Sentence.unscoped.where(type: nil).find_each do |sentence|
      sentence.type = 'Axiom'
      sentence.save!
    end
  end

  def self.down
    Sentence.unscoped.where(type: 'Axiom').find_each do |sentence|
      sentence.type = nil
      sentence.save!
    end
  end
end
