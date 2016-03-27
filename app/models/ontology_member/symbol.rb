# This model is namespaced in the module OntologyMember because the class
# Symbol is already taken by ruby.
module OntologyMember
  class Symbol < LocIdBaseModel
    include Metadatable
    include Symbol::Searching
    include Symbol::Readability

    belongs_to :ontology
    belongs_to :symbol_group
    has_and_belongs_to_many :sentences
    has_and_belongs_to_many :oops_responses

    # associations for SineAxiomSelection
    has_one :sine_symbol_commonness, class_name: SineSymbolCommonness,
                                     dependent: :destroy
    has_many :sine_symbol_axiom_triggers, dependent: :destroy

    has_many :loc_ids, as: :assorted_object

    attr_accessible :label, :comment

    scope :kind, ->(kind) { where kind:  kind }

    def self.find_with_locid(locid, _iri = nil)
      LocId.where(locid: locid).first.try(:assorted_object)
    end

    def self.groups_by_kind
      groups = select('kind, count(*) AS count').group(:kind).
        order('count DESC, kind').all
      groups << Struct.new(:kind, :count).new('Symbol', 0) if groups.empty?
      groups
    end

    def to_s
      display_name || name
    end

    def locid
      LocId.where(assorted_object_id: id,
                  assorted_object_type: self.class.to_s,
                 ).first.try(:locid)
    end

    def generate_locid_string
      sep = '//'
      locid_portion =
        if name.include?('://')
          Rack::Utils.escape_path(name)
        else
          name
        end
      "#{ontology.locid}#{sep}#{locid_portion}"
    end
  end
end
