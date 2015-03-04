module OntologyVersion::Parsing

  extend ActiveSupport::Concern
  include Hets::ErrorHandling

  included do
    @queue = 'hets'

    after_create :async_parse, :if => :commit_oid?
    attr_accessor :fast_parse
  end

  def do_not_parse!
    @deactivate_parsing = true
  end

  def async_parse(*args)
    if !@deactivate_parsing
      update_state! :pending

      if @fast_parse
        async :parse_fast
      else
        async :parse_full
      end
    end
  end

  def parse(refresh_cache: false, structure_only: self.fast_parse)
    update_state! :processing

    do_or_set_failed do
      # run hets if necessary
      cmd, input_io = generate_xml(structure_only: structure_only)
      return if cmd == :abort

      # Import version
      ontology.import_version(self, self.user, input_io)

      update_state! :done
    end
  end

  # generate XML by passing the raw ontology to Hets
  def generate_xml(structure_only: false)
    input_io = Hets.parse_via_api(ontology,
      Hets::Options.new(access_token: generate_access_token,
        structure_only: structure_only,
        url_catalog: ontology.repository.url_maps))
    [:all_is_well, input_io]
  rescue Hets::ExecutionError => e
    handle_hets_execution_error(e, self)
    e.abort_execution ? [:abort, nil] : raise(e)
  end

  def generate_access_token
    if !repository.is_private
      access_token = AccessToken.create_for(self)
      repository.access_tokens << access_token
      repository.save!

      access_token
    end
  end

  def parse_full
    parse(structure_only: false)
  end

  def parse_fast
    parse(structure_only: true)
  end
end
