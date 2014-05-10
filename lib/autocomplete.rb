#
# Autocompleter that searches the given scopes and excludes optional ids
#
class Autocomplete

  class InvalidScope < Exception; end

  # you need these scopes in all searchable models
  AUTOCOMPLETE_SCOPE = :autocomplete_search
  ID_EXCLUSION_SCOPE = :without_ids

  # to split the string of excluded ids
  ID_DELIMITER = ','

  def initialize
    # clazz => excluded_ids
    @scopes = {}
  end

  # adds a scope to the autocompleter
  def add_scope(name, without_ids="")
    clazz = name.to_s.constantize rescue nil
    raise InvalidScope, "invalid scope: #{name}" unless clazz.respond_to?(AUTOCOMPLETE_SCOPE)

    without_ids    = without_ids.to_s.split(ID_DELIMITER) unless without_ids.is_a?(Array)
    @scopes[clazz] = without_ids
  end

  # search the added scopes
  def search(query, limit = 10)
    raise "no scopes added" if @scopes.empty?

    result = []

    @scopes.each do |clazz, without_ids|

      scope = clazz

      # exclude the given ids
      scope = scope.send ID_EXCLUSION_SCOPE, without_ids if without_ids.any?

      # finally apply the search scope
      scope = scope.send AUTOCOMPLETE_SCOPE, query

      result += scope.limit(limit).all
    end

    result
  end

end
