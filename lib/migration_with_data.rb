# This provides convenience-methods to directly operate on the database, without
# relying on the existence of model methods (except for `id`).
# It allows to perform data migrations which won't fail because of renamed
# or removed model-methods.
class MigrationWithData < ActiveRecord::Migration
  include SqlHelper
  def select_attributes(record, *keys,
                        search_column: :id, search_value: record.id)
    attributes = keys.map do |key|
      record.class.where(search_column => search_value).pluck(key).first
    end
    Hash[keys.zip(attributes)]
  end

  def select_attributes_class(klass, search_value, *keys, search_column: :id)
    attributes = keys.map do |key|
      klass.where(search_column => search_value).pluck(key).first
    end
    Hash[keys.zip(attributes)]
  end

  # create_unsafe skips callbacks and validations.
  def create_unsafe(record)
    klass = record.class
    skip_all_callbacks(klass)
    record.save(validate: false)
    set_all_callbacks(klass)
  end

  # update_columns skips callbacks and validations.
  def update_columns(record, **attributes)
    attributes.each do |key, value|
      record.update_column(key, value)
    end
  end

  # update_attributes! calls callbacks and validations (by calling save!).
  def update_attributes!(record, **attributes)
    record.update_attributes!(attributes, without_protection: true)
  end

  protected

  # {skip,set}_all_callbacks was found on
  # http://stackoverflow.com/questions/6537324/skipping-callbacks-and-validation/6538007#6538007
  def skip_all_callbacks(klass)
    [:validation, :save, :create, :commit].each do |name|
      klass.send("_#{name}_callbacks").each do |_callback|
        if _callback.filter != :enhanced_write_lobs
          klass.skip_callback(name, _callback.kind, _callback.filter)
        end
      end
    end
  end

  def set_all_callbacks(klass)
    [:validation, :save, :create, :commit].each do |name|
      klass.send("_#{name}_callbacks").each do |_callback|
        if _callback.filter != :enhanced_write_lobs
          klass.set_callback(name, _callback.kind, _callback.filter)
        end
      end
    end
  end
end
