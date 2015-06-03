class AddSlugToLogicMapping < ActiveRecord::Migration
  def change
    add_column :logic_mappings, :slug, :string
    LogicMapping.find_each do |logic_mapping|
      iri = LogicMapping.where(id: logic_mapping).pluck(:iri).first
      name = iri.split('/').last
      logic_mapping.update_attributes!({slug: name}, without_protection: true)
    end
  end
end
