class AddLocidToLogicMapping < ActiveRecord::Migration
  def up
    add_column :logic_mappings, :locid, :text
    LogicMapping.find_each do |logic_mapping|
      iri = LogicMapping.where(id: logic_mapping.id).pluck(:iri).first
      name = iri.split('/').last
      logic_mapping.update_attributes!({locid: "/logic-mappings/#{name}"},
                                       without_protection: true)
    end
  end

  def down
    remove_column :logic_mappings, :locid
  end
end
