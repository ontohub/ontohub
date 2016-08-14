# Monkey-Patch using Method Wrapping as described in
# http://stackoverflow.com/questions/4470108/when-monkey-patching-a-method-can-you-call-the-overridden-method-from-the-new-i/4471202#4471202
module ActionDispatch
  module Routing
    module PolymorphicRoutes
      original_definition_of_polymorphic_url = instance_method(:polymorphic_url)

      define_method(:polymorphic_url) do |record_or_hash_or_array, options = {}|
        base_url = options[:routing_type] == :path ? '' : ontohub_url_authority

        if record_or_hash_or_array.respond_to?(:locid)
          build_locid_url(base_url, record_or_hash_or_array, [], {})
        elsif record_or_hash_or_array.is_a?(Array) &&
              record_or_hash_or_array.first.respond_to?(:locid)
          record = record_or_hash_or_array.shift

          query_components =
            if record_or_hash_or_array.last.is_a?(Hash)
              record_or_hash_or_array.pop
            else
              {}
            end

          commands = record_or_hash_or_array

          build_locid_url(base_url, record, commands, query_components)
        else
          original_definition_of_polymorphic_url.
            bind(self).call(record_or_hash_or_array, options)
        end
      end

      private
      def ontohub_url_authority
        if respond_to?(:request) && method(:request).arity == 0 &&
           request.is_a?(ActionDispatch::Request)
          request.base_url
        else
          Hostname.url_authority
        end
      end

      def build_locid_url(base_url, record, commands, query_components)
        raise ArgumentError.new("locid not set for #{record}") if !record.respond_to?(:locid) || record.locid.nil?
        url = "#{base_url}#{URI.escape(record.locid)}"
        url << "///#{commands.join('///')}" if commands.any?
        url << "?#{query_components.to_query}" if query_components.any?
        url
      end
    end
  end
end
