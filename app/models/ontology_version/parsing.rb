module OntologyVersion::Parsing

  extend ActiveSupport::Concern

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
      retrieve_available_provers_for_self_and_children

      update_state! :done
    end
  end

  # generate XML by passing the raw ontology to Hets
  def generate_xml(structure_only: false)
    repo = ontology.repository
    hets_options =
      Hets::HetsOptions.new(:'url-catalog' => repo.url_maps,
                            :'access-token' => repo.generate_access_token)
    input_io = Hets.parse_via_api(ontology, hets_options,
                                  structure_only: structure_only)
    [:all_is_well, input_io]
  end

  def parse_full
    parse(structure_only: false)
  end

  def parse_fast
    parse(structure_only: true)
  end

  def retrieve_available_provers_for_self_and_children
    retrieve_available_provers
    if ontology.distributed?
      ontology.children.each do |child|
        child.versions.find_by_commit_oid(commit_oid).retrieve_available_provers
      end
    end
  end

  def retrieve_available_provers
    repo = ontology.repository
    hets_options =
      Hets::ProversOptions.new(:'url-catalog' => repo.url_maps,
                               :'access-token' => repo.generate_access_token,
                               ontology: ontology)
    provers_io = Hets.provers_via_api(ontology, hets_options)
    Hets::Provers::Importer.new(self, provers_io).import
  end
end
