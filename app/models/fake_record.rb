# FakeRecord Mimics ActiveRecord::Base, so you can use your record like a model.
#   It needs its subclasses to define two methods:
#   - initialize(*args, &block) for create and build to work, and
#   - save! for create and save to work.
#   save! is supposed to raise a RecordNotSavedError when the record couldn't be
#   saved, e.g. because of validation errors.
class FakeRecord

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  class Error < ::StandardError; end
  class RecordNotSavedError < Error; end

  def self.create(attributes = nil, options = {}, &block)
    if attributes.is_a?(Array)
      attributes.collect { |attr| create(attr, options, &block) }
    else
      object = new(attributes, options)
      yield(object) if block_given?
      object.save
      object
    end
  end

  def self.build(*args, &block)
    new(*args, &block)
  end

  def save
    save!
  rescue RecordNotSavedError
    nil
  end

end
