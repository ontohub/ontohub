class PreloadLocids < ActiveRecord::Migration
  def self.up
    LocId.where(specific_type: Sentence.descendants.map(&:to_s)).find_each do |object|
      object.specific_type = Sentence.to_s
      object.save
    end
  end

  def self.down
    Sentence.find_each do |object|
      klass = object.class.to_s
      loc_id = object.loc_ids.first
      loc_id.specific_type = klass
      loc_id.save
    end
  end
end
