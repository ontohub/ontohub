#
# Helper-Class for rendering a list of relations
#
class RelationList

  attr_reader :model, :collection_path, :collection, :scope, :association

  #
  # first argument: restful path to the collection of related objects
  # second argument: options hash that may contain the following elements:
  #
  # :scope       => scope for the autocompleter
  # :model       => class that represents the relation
  # :association => name of the activerecord-association
  # :collection  => collection of all permissions
  def initialize(collection_path, options)
    @collection_path = collection_path
    @editable        = true

    options.each do |key,value|
      case key
        when :model, :collection, :association
          instance_variable_set("@#{key}", value)
        when :scope
          value = [value] unless value.is_a?(Array)
          value.each do |v|
            raise "Scope '#{v}' is not a class" unless v.is_a?(Class)
          end
          @scope = value.map(&:to_s).join(",")
        else
          raise ArgumentError, "invalid option: #{key}"
      end
    end

    # check required attributes
    for key in %w( model scope collection )
      raise ArgumentError, "#{key} is not set" unless instance_variable_get("@#{key}")
    end
  end

  def polymorphic?
    @model.reflect_on_association(@association).options[:polymorphic]==true
  end

  # path for rendering a PermissionsList instance
  def to_partial_path
    'relation_list/relation_list'
  end

  def form_path
    partial_path :form
  end

  def relation_partial_path
    partial_path model_underscore
  end

  # path to a specific partial of the permission list
  def partial_path(name)
    "#{model_underscore.pluralize}/#{name}"
  end

  def model_underscore
    @model.name.underscore
  end

  def t(key)
    I18n.t(key, :scope => "relation_list.#{model_underscore}" )
  end

  def to_data
    {
      'data-model'       => model,
      'data-scope'       => scope,
      'data-polymorphic' => polymorphic? && 'true',
      'data-association' => association
    }
  end

end
