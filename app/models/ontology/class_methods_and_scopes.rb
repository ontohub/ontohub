module Ontology::ClassMethodsAndScopes
  extend ActiveSupport::Concern

  included do
    equal_scope 'repository_id'

    scope :without_parent, -> { where('ontologies.parent_id' => nil) }

    scope :basepath, ->(path) do
      joins(:ontology_version).where('ontology_versions.basepath' => path)
    end

    scope :list, -> do
      includes(:logic).
        order('ontologies.state asc, ontologies.symbols_count desc')
    end

    scope :with_path, ->(path) do
      condition = <<-CONDITION
        ("ontology_versions"."file_extension" = :extname)
          OR (("ontology_versions"."file_extension" IS NULL)
            AND ("ontologies"."file_extension" = :extname))
      CONDITION

      with_basepath(File.basepath(path)).
        where(condition, extname: File.extname(path)).
        readonly(false)
    end

    scope :with_basepath, ->(path) do
      join = <<-JOIN
        LEFT JOIN "ontology_versions"
        ON "ontologies"."ontology_version_id" = "ontology_versions"."id"
      JOIN

      condition = <<-CONDITION
        ("ontology_versions"."basepath" = :path)
          OR (("ontology_versions"."basepath" IS NULL)
            AND ("ontologies"."basepath" = :path))
      CONDITION

      joins(join).where(condition, path: path).readonly(false)
    end

    scope :parents_first, -> do
      order('(CASE WHEN ontologies.parent_id IS NULL THEN 1 ELSE 0 END) DESC,'\
        ' ontologies.parent_id asc')
    end

    # searching scopes
    scope :filter_by_ontology_type, ->(type_id) do
      where(ontology_type_id: type_id)
    end

    scope :filter_by_project, ->(project_id) do
      joins(:projects).where("projects.id = #{project_id}")
    end

    scope :filter_by_formality, ->(formality_id) do
      where(formality_level_id: formality_id)
    end

    scope :filter_by_license, ->(license_id) do
      joins(:license_models).where("license_models.id = #{license_id}")
    end

    scope :filter_by_task, ->(task_id) do
      joins(:tasks).where("tasks.id = #{task_id}")
    end

    # state scopes
    scope :state, ->(*states) do
      where state: states.map(&:to_s)
    end

    # access scopes
    scope :pub, -> do
      joins(:repository).
        # simulating scope: repository.active
        where('repositories.is_destroying = ?', false).
        where("repositories.access NOT LIKE 'private%'")
    end
    scope :accessible_by, ->(user) do
      if user
        joins(:repository).
          # simulating scope: repository.active
          where('repositories.is_destroying = ?', false).
          where(Repository::ACCESSIBLE_BY_SQL_QUERY, user, user)
      else
        pub
      end
    end
  end

  module ClassMethods
    def find_with_locid(locid, iri = nil)
      ontology = where(locid: locid).first

      if ontology.nil? && iri
        ontology = AlternativeIri.where('iri LIKE ?', '%' << iri).
          first.try(:ontology)
      end

      ontology
    end

    def find_with_iri(iri)
      locid = iri_to_locid(iri)
      ontology = where('locid LIKE ?', '%' << locid).first
      if ontology.nil?
        ontology = AlternativeIri.where('iri LIKE ?', '%' << iri).
          first.try(:ontology)
      end

      ontology
    end

    private
    def iri_to_locid(iri)
      if iri.start_with?('/')
        # iri can be considered as locid
        iri
      else
        "/#{iri.split('/', 4).last}"
      end
    end
  end
end
