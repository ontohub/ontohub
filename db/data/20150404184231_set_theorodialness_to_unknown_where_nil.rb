class SetTheorodialnessToUnknownWhereNil < ActiveRecord::Migration
  def self.up
    LogicMapping.find_each do |logic_mapping|
      unless logic_mapping.theoroidalness
        logic_mapping.theoroidalness = 'unknkown'
        logic_mapping.save!
      end
    end
  end

  def self.down
    LogicMapping.find_each do |logic_mapping|
      if logic_mapping.theoroidalness == 'unknown'
        logic_mapping.theoroidalness = nil
        logic_mapping.save!
      end
    end
  end
end
