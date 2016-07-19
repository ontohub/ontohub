module OntologyVersion::Parsing

  extend ActiveSupport::Concern

  included do
    @queue = 'hets'

    after_create :async_parse, :if => :commit_oid?
    attr_accessor :fast_parse
    attr_accessor :files_to_parse_afterwards
  end

  def do_not_parse!
    @deactivate_parsing = true
  end

  def async_parse(*args)
    if !@deactivate_parsing
      update_state! :pending

      Sidekiq::RetrySet.new.each do |job|
        job.kill if job.args.first == id
      end

      OntologyParsingWorker.
        perform_async([[id,
                        {fast_parse: @fast_parse,
                         files_to_parse_afterwards: files_to_parse_afterwards},
                        1]])
    end
  end

  def parse(refresh_cache: false, structure_only: self.fast_parse,
            files_to_parse_afterwards: self.files_to_parse_afterwards)
    files_to_parse_afterwards ||= []
    update_state! :processing

    do_or_set_failed do
      # run hets if necessary
      cmd, input_io = generate_xml(structure_only: structure_only)
      return if cmd == :abort

      # Import version
      ontology.import_version(self, pusher, input_io)
      retrieve_available_provers_for_self_and_children

      update_state!(:done)
      ontology.children.each do |child|
        child.versions.where(commit_oid: commit_oid).first.update_state!(:done)
        child.versions.where(commit_oid: commit_oid).first.save!
      end
    end

    files_to_parse_afterwards.each do |path|
      ontology_version_options = OntologyVersionOptions.new(path, pusher,
                                                            do_not_parse: false)
      version = OntologySaver.new(repository).
        save_ontology(commit_oid, ontology_version_options)
    end
  end

  # generate XML by passing the raw ontology to Hets
  def generate_xml(structure_only: false)
    input_io = Hets.parse_via_api(ontology, ontology.hets_options,
                                  structure_only: structure_only)
    [:all_is_well, input_io]
  end

  def parse_full(files_to_parse_afterwards = [])
    parse(structure_only: false, files_to_parse_afterwards: files_to_parse_afterwards)
  end

  def parse_fast(files_to_parse_afterwards = [])
    parse(structure_only: true, files_to_parse_afterwards: files_to_parse_afterwards)
  end

  def retrieve_available_provers_for_self_and_children
    retrieve_available_provers
    if ontology.distributed?
      ontology.children.each do |child|
        child.versions.find_by_commit_oid(commit_oid).
          try(:retrieve_available_provers)
      end
    end
  end

  def retrieve_available_provers
    hets_options = Hets::ProversOptions.new(**ontology.hets_options.options,
                                            ontology: ontology)
    provers_io = Hets.provers_via_api(ontology, hets_options)
    Hets::Provers::Importer.new(self, provers_io).import
  end
end
