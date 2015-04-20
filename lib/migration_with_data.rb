class MigrationWithData < ActiveRecord::Migration
  def select_attributes(record, *keys)
    attributes = keys.map do |key|
      record.class.where(id: record.id).pluck(key).first
    end
    Hash[keys.zip(attributes)]
  end

  def update_attributes!(record, **attributes)
    record.update_attributes!(attributes, without_protection: true)
  end
end
