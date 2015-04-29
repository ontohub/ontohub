class SetTheoroidalnessToUnknownWhereNil < MigrationWithData
  def up
    LogicMapping.where(theoroidalness: nil).find_each do |logic_mapping|
      update_attributes!(logic_mapping, theoroidalness: 'unknkown')
    end
    change_column :logic_mappings, :theoroidalness, :string,
                  null: false, default: 'unknown'
  end

  def down
    LogicMapping.where(theoroidalness: 'unknown').find_each do |logic_mapping|
      update_attributes!(logic_mapping, theoroidalness: nil)
    end
    change_column :logic_mappings, :theoroidalness, :string, null: true
  end
end
