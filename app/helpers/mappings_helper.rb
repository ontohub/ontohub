module MappingsHelper
  def sort_mapping_list(collection)
    hash = {}

    collection.each_with_index do |mapping, i|
      if mapping.symbol_mappings.empty?
        hash["empty#{i}"] = [{mapping: mapping, target: ''}]
      else
        mapping.symbol_mappings.each do |symbol_mapping|
          sym = mapping.source.to_s.to_sym
          hash[sym] ||= []
          hash[sym] << {mapping: mapping, target: symbol_mapping.target}
        end
      end
    end

    hash
  end
end
