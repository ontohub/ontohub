module Slug
  extend ActiveSupport::Concern

  included do
    attr_accessible :slug
    before_save :set_slug, if: :set_slug?
  end

  module ClassMethods
    def slug_base(attribute)
      @slug_base = attribute
    end

    def slug_condition(method)
      @slug_condition = method
    end
  end

  def to_param
    slug
  end

  protected

  def set_slug?
    if slug_condition_class_instance_variable.nil?
      send("#{slug_base_class_instance_variable}_changed?")
    elsif slug_condition_class_instance_variable.respond_to?(:call)
      slug_condition_class_instance_variable.call
    else
      send(slug_condition_class_instance_variable)
    end
  end

  def set_slug
    self.slug = send(slug_base_class_instance_variable).
      gsub(/\s/, '_').
      gsub(/[*.=]/,
           '*' => 'Star',
           '=' => 'Eq')
  end

  def slug_base_class_instance_variable
    self.class.instance_variable_get(:'@slug_base')
  end

  def slug_condition_class_instance_variable
    self.class.instance_variable_get(:'@slug_condition')
  end
end
