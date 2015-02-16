module MappingsHelper
  def sort_mapping_list(collection)
    hash = {}

    collection.each_with_index do |mapping, i|
      if mapping.symbol_mappings.empty?
        set_empty_mapping!(hash, mapping, "empty#{i}")
      else
        add_symbol_mappings!(hash, mapping)
      end
    end

    hash
  end

  private
  def set_empty_mapping!(hash, mapping, name)
    hash[name] = [{mapping: mapping, target: ''}]
    hash
  end

  def add_symbol_mappings!(hash, mapping)
    mapping.symbol_mappings.each do |symbol_mapping|
      sym = mapping.source.to_s.to_sym
      hash[sym] ||= []
      hash[sym] << {mapping: mapping, target: symbol_mapping.target}
    end
    hash
  end
end
