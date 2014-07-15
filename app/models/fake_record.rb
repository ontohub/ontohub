# Mimics ActiveRecord::Base
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
