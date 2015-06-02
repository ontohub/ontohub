module Hets
  class HetsOptions
    attr_reader :options

    def self.from_hash(hash)
      new(hash['options'])
    end

    def self.from_json(json)
      from_hash(JSON.parse(json))
    end

    def initialize(opts = {})
      @options = opts.dup
      prepare
    end

    def add(**opts)
      @options.merge!(opts.dup)
      prepare
      self
    end

    def merge!(hets_options)
      add(hets_options.options)
    end

    def to_json
      {'options' => options}.to_json
    end

    def ==(other)
      options == other.options
    end

    protected

    def prepare
      remove_nil_fields
      prepare_url_catalog
      prepare_access_token
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

    def prepare_access_token
      if @options[:'access-token'].is_a?(AccessToken)
        @options[:'access-token'] = @options[:'access-token'].to_s
      end
    end
  end
end
