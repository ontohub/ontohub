# This provides convenience-methods to directly operate on the database, without
# relying on the existence of model methods (except for `id`).
# It allows to perform data migrations which won't fail because of renamed
# or removed model-methods.
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
