# 
# Autocompleter that searches the given scopes and excludes optional ids
# 
class Autocomplete
  
  class InvalidScope < Exception; end
  
  SCOPES = %w( user team )
  
  def initialize
    # scope_name => excluded_ids
    @scopes = {}
  end
  
  # adds a scope to the autocompleter
  def add_scope(name, without_ids="")
    raise InvalidScope, "invalid scope: #{name}" unless SCOPES.include?(name)
    
    without_ids   = without_ids.to_s.split(",") unless without_ids.is_a?(Array)
    @scopes[name] = without_ids
  end
  
  # search the added scopes
  def search(query)
    result = []
    
    @scopes.each do |name, without_ids|
      
      # get class of scope
      scope = name.camelize.constantize
      
      # exclude the given ids
      scope = scope.without_ids(without_ids) if without_ids.any?
      
      # finally apply the search scope
      scope = scope.autocomplete_search(query)
      
      result += scope.all
    end
    
    result
  end
  
end