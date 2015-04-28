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
    slug_condition = self.class.instance_variable_get(:'@slug_condition')
    send(slug_condition)
  end

  def set_slug
    slug_base = self.class.instance_variable_get(:'@slug_base')
    self.slug = send(slug_base).
      gsub(/\s/, '_').
      gsub(/[*.=]/,
           '*' => 'Star',
           '=' => 'Eq')
  end
end
