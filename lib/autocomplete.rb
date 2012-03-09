class Autocomplete
  
  class InvalidScope < Exception; end
  
  SCOPES = %w( user team )
  
  attr_reader :result
  
  def initialize(scopes, query)
    scopes  = [] if scopes.blank?
    scopes  = scopes.split(',') if scopes.is_a?(String)
    @result = []
    
    for scope in scopes.each
      raise InvalidScope, "invalid scope: #{scope}" unless SCOPES.include?(scope)
      
      # get class of scope
      model = scope.camelize.constantize
      
      @result += model.autocomplete_search(query).all
    end
    
    @result
  end
  
end