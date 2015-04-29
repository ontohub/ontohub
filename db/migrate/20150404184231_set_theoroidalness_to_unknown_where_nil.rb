class SetTheoroidalnessToUnknownWhereNil < MigrationWithData
  def up
    LogicMapping.where(theoroidalness: nil).find_each do |logic_mapping|
      update_attributes!(logic_mapping, theoroidalness: 'unknkown')
    end
  end

  def down
    LogicMapping.where(theoroidalness: 'unknown').find_each do |logic_mapping|
      update_attributes!(logic_mapping, theoroidalness: nil)
    end
  end
end
