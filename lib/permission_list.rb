# 
# Helper-Class for rendering a permission list
# 
class PermissionList
  
  attr_reader :model, :collection_path, :collection, :scope, :polymorphic
  
  # 
  # first argument: restful path to the permissions collection
  # second argument: options hash that may contain the following elements:
  # 
  # :scope       => scope for the autocompleter
  # :collection  => all current permissions to show
  # :model       => class that represents the permissions
  # :editable    => boolean, true if the permission list should be editable
  # :polymorphic => name of the attribute, if polymorphic
  # 
  def initialize(collection_path, options)
    @collection_path = collection_path
    @editable        = true
    
    options.each do |key,value|
      case key
        when :collection
          @collection = value
        when :editable
          @editable = value
        when :model
          @model = value
        when :polymorphic
          @polymorphic = value
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
    
    raise ArgumentError, "no model given" unless @model
    raise ArgumentError, "no collection given" unless @collection
    raise ArgumentError, "no scope given"      if @scope.blank?
  end
  
  def editable?
    @editable
  end
  
  # path for rendering a PermissionsList instance
  def to_partial_path
    'permission_list/permission_list'
  end
  
  def form_path
    partial_path :form
  end
  
  def permission_path
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
    I18n.t(key, :scope => "permission_list.#{model_underscore}" )
  end
  
end