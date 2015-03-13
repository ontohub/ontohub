module Hets
  class HetsOptions
    attr_reader :options

    def self.from_hash(hash)
      new(hash['options'])
    end

    def initialize(opts = {})
      @options = opts.dup
      prepare
    end

    def add(**opts)
      @options.merge!(opts.dup)
      prepare
    end

    protected

    def prepare
      remove_nil_fields
      prepare_url_catalog
    end

    def remove_nil_fields
      nil_valued_keys = @options.keys.select { |key| @options[key].nil? }
      nil_valued_keys.each { |key| @options.delete(key) }
    end

    def prepare_url_catalog
      @options[:'url-catalog'].try(:compact!)
      if @options[:'url-catalog'].blank?
        @options.delete(:'url-catalog')
      end
    end
  end
end