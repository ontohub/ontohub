module Hets
  class JSONParser
    attr_accessor :resource, :callback, :parser
    attr_accessor :hierarchy, :keys_hierarchy

    def initialize(resource)
      self.resource = resource
      self.parser = JSON::Stream::Parser.new
      initialize_parser_hooks
    end

    def parse(callback: nil)
      self.callback = callback
      input = resource.respond_to?(:close) ? resource : File.open(resource)
      parser << input.read
      input.close
    end

    protected

    def initialize_parser_hooks
      parser.start_document { document_start }
      parser.end_document   { document_end }
      parser.start_object   { object_start }
      parser.end_object     { object_end }
      parser.start_array    { array_start }
      parser.end_array      { array_end }
      parser.key            { |k| key(k) }
      parser.value          { |v| value(v) }
    end

    def call_back(key_name, order, *args)
      callback.process(key_name.to_sym, order, *args) if callback
    end

    def select_callback(_order)
      # This method is supposed to be overwritten by a subclass.
      raise NotImplementedError
    end

    def process_key(_key)
      # This method is supposed to be overwritten by a subclass.
      raise NotImplementedError
    end

    def process_value(_value, _key = nil)
      # This method is supposed to be overwritten by a subclass.
      raise NotImplementedError
    end

    def document_start
      self.hierarchy = []
      self.keys_hierarchy = []
      call_back(:document, :start)
    end

    def document_end
      call_back(:document, :end)
    end

    def object_start
      hierarchy << :object
      select_callback(:start)
    end

    def object_end
      select_callback(:end)
      hierarchy.pop
      hierarchy.pop if key?(hierarchy.last)
    end

    def array_start
      hierarchy << :array
      select_callback(:start)
    end

    def array_end
      select_callback(:end)
      hierarchy.pop
      hierarchy.pop if key?(hierarchy.last)
    end

    def key(k)
      hierarchy << k
      keys_hierarchy << k
      process_key(k)
    end

    def value(v)
      if in_array?
        process_value(v)
      elsif key?(hierarchy.last)
        process_value(v, current_key)
        hierarchy.pop
        keys_hierarchy.pop
      else
      end
    end

    # helpers
    def current_key
      keys_hierarchy.last
    end

    def key?(element)
      element.is_a?(String)
    end

    def in_object?
      hierarchy.last == :object
    end

    def in_array?
      hierarchy.last == :array
    end
  end
end
