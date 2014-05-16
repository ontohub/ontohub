# A logic_mapping propulation procedure.
#
# TODO Transform this code in an iterator to enable unit testing
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
class LogicMappingPopulation

  # A triple store with logic_mappings
  @store

  def initialize(store, logic_map)
    @store = store
    @logic_map = logic_map
  end

  def list()
    type_iri = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
    label_iri = 'http://www.w3.org/2000/01/rdf-schema#label'
    comment_iri = 'http://www.w3.org/2000/01/rdf-schema#comment'
    defined_iri = 'http://www.w3.org/2000/01/rdf-schema#isDefinedBy'
    mapping_type_iri = 'http://purl.net/dol/1.0/rdf#LogicMapping'
    default_iri = 'http://purl.net/dol/1.0/rdf#DefaultMapping'
    maps_from_iri = 'http://purl.net/dol/1.0/rdf#mapsFrom'
    maps_to_iri = 'http://purl.net/dol/1.0/rdf#mapsTo'
    status_iri = 'http://purl.net/dol/1.0/standardization#standardizationStatus'
    faithfulness_iris = [
      'http://purl.net/dol/1.0/rdf#UnfaithfulMapping',
      'http://purl.net/dol/1.0/rdf#FaithfulMapping',
      'http://purl.net/dol/1.0/rdf#ModelExpansiveMapping',
      'http://purl.net/dol/1.0/rdf#ModelBijectiveMapping',
      'http://purl.net/dol/1.0/rdf#EmbeddingMapping',
      'http://purl.net/dol/1.0/rdf#SubLogic'
    ]
    theoroidalness_iris = [
      'http://purl.net/dol/1.0/rdf#PlainMapping',
      'http://purl.net/dol/1.0/rdf#SimpleTheoroidalMapping',
      'http://purl.net/dol/1.0/rdf#TheoroidalMapping',
      'http://purl.net/dol/1.0/rdf#GeneralizedMapping'
    ]
    exactness_iris = [
      'http://purl.net/dol/1.0/rdf#InexactMapping',
      'http://purl.net/dol/1.0/rdf#WeaklyMonoExactMapping',
      'http://purl.net/dol/1.0/rdf#WeaklyExactMapping',
      'http://purl.net/dol/1.0/rdf#ExactMapping'
    ]

    mapping_iris = @store.subjects(type_iri, mapping_type_iri)
    mapping_iris.map do |mapping_iri|
      mapping_names = @store.objects(mapping_iri, label_iri)
      mapping_defis = @store.objects(mapping_iri, defined_iri)
      mapping_source_ids = @store.objects(mapping_iri, maps_from_iri)
      mapping_target_ids   = @store.objects(mapping_iri, maps_to_iri)
      mapping_types = @store.objects(mapping_iri, type_iri)
      mapping_name = mapping_names == [] ? mapping_iri : mapping_names[0]
      mapping_defi = mapping_defis == [] ? mapping_iri : mapping_defis[0]
      mapping_source = mapping_source_ids == [] ? nil : @logic_map[mapping_source_ids[0]]
      mapping_target = mapping_target_ids == [] ? nil : @logic_map[mapping_target_ids[0]]
      default = false
      faithfulness_i = 0
      theoroidalness_i = 0
      exactness_i = 0
      mapping_types.each do |type|
        default = type == default_iri ? true : default
        index = faithfulness_iris.index(type)
        faithfulness_i = index != nil ? index : faithfulness_i
        index = theoroidalness_iris.index(type)
        theoroidalness_i = index != nil ? index : theoroidalness_i
        index = exactness_iris.index(type)
        exactness_i = index != nil ? index : exactness_i
      end
      if faithfulness_i > 2 then
        exactness_i = 3
      end

      LogicMapping.new \
        :iri => mapping_iri,
        #:name => mapping_name,
        :defined_by => mapping_defi,
        :source_id => mapping_source.iri,
        :target_id => mapping_target.iri,
        :source => mapping_source,
        :target => mapping_target,
        :default => default,
        :faithfulness => LogicMapping::FAITHFULNESSES[faithfulness_i],
        :theoroidalness => LogicMapping::THEOROIDALNESSES[theoroidalness_i],
        :exactness => LogicMapping::EXACTNESSES[exactness_i]
    end
  end
end

