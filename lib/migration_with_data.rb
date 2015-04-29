# This provides convenience-methods to directly operate on the database, without
# relying on the existence of model methods (except for `id`).
# It allows to perform data migrations which won't fail because of renamed
# or removed model-methods.
class MigrationWithData < ActiveRecord::Migration
  def select_attributes(record, *keys,
                        search_column: :id, search_value: record.id)
    attributes = keys.map do |key|
      record.class.where(search_column => search_value).pluck(key).first
    end
    Hash[keys.zip(attributes)]
  end

  def update_attributes!(record, **attributes)
    if record.persisted?
      attributes.each do |key, value|
        record.update_column(key, value)
      end
    else
      record.update_attributes!(attributes, without_protection: true)
    end
  end
end
