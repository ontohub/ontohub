# A service class for saving an ontology, e.g. when its file is added to
# the git repository.
class OntologySaver
  attr_accessor :repository

  def initialize(repository)
    self.repository = repository
  end

  def save_ontology(commit_oid, ontology_version_options, changed_files: [])
    # We expect that this method is only called, when we can expect an ontology
    # in this file.
    file_extension = File.extname(ontology_version_options.filepath)
    return unless Ontology.file_extensions.include?(file_extension)
    return if already_updated_in_commit?(commit_oid, ontology_version_options)
    ActiveRecord::Base.transaction do
      ontology = find_or_create_ontology(ontology_version_options)

      return unless repository.master_file?(ontology, ontology_version_options)
      return if ontology.versions.find_by_commit_oid(commit_oid)

      version = create_version(ontology, commit_oid, ontology_version_options,
                               changed_files)
      ontology.present = true
      ontology.save!

      version
    end
  end

  def suspended_save_ontologies(options={})
    versions = []
    commits_count = 0
    highest_change_file_count = 0
    repository.walk_commits(options) { |commit|
      commits_count += 1
      current_file_count = 0
      changed_files = repository.git.changed_files(commit.oid)
      changed_files.each { |f|
        current_file_count += 1
        if f.added? || f.modified?
          mark_ontology_as_having_file(f.path, has_file: true)
          ontology_version_options = OntologyVersionOptions.new(
            f.path,
            options.delete(:user),
            fast_parse: repository.has_changed?(f.path, commit.oid),
            do_not_parse: true)
          versions << save_ontology(commit.oid, ontology_version_options,
                                    changed_files: changed_files)
        elsif f.renamed?
          ontology_version_options = OntologyVersionOptions.new(
            f.path,
            options.delete(:user),
            fast_parse: repository.has_changed?(f.path, commit.oid),
            do_not_parse: true,
            previous_filepath: f.delta.old_file[:path])
          versions << save_ontology(commit.oid, ontology_version_options,
                                    changed_files: changed_files)
        elsif f.deleted?
          mark_ontology_as_having_file(f.path, has_file: false)
        end
      }
      highest_change_file_count = [highest_change_file_count,
                                   current_file_count].max
    }

    priority = applicable_for_priority?(commits_count,
                                        highest_change_file_count)
    schedule_batch_parsing(versions, priority_mode: priority)
  end

  def mark_ontology_as_having_file(path, has_file: false)
    ontos = repository.ontologies.with_path(path)
    return unless ontos.any? { |onto| onto.has_file != has_file }
    ontos.each do |onto|
      onto.has_file = has_file
      onto.save
    end
  end

  protected

  def already_updated_in_commit?(commit_oid, ontology_version_options)
    basepath = File.basepath(ontology_version_options.filepath)
    file_extension = File.extname(ontology_version_options.filepath)
    repository.ontology_versions.where(commit_oid: commit_oid,
                                       basepath: basepath,
                                       file_extension: file_extension).any?
  end

  def find_or_create_ontology(ontology_version_options)
    ontology = find_existing_ontology(ontology_version_options)

    if !ontology
      basepath = File.basepath(ontology_version_options.filepath)

      ontology = create_ontology(ontology_version_options.filepath)
    end

    ontology
  end

  def find_existing_ontology(ontology_version_options)
    repository.ontologies.with_basepath(
      File.basepath(ontology_version_options.pre_saving_filepath)).
      without_parent.first
  end

  def create_ontology(filepath)
    ontology = corresponding_ontology_klass(filepath).new
    ontology.basepath = File.basepath(filepath)
    ontology.file_extension = File.extname(filepath)
    ontology.name = filepath.split('/')[-1].split(".")[0].capitalize
    ontology.repository = repository
    ontology.present = true
    ontology.save!

    ontology
  end

  def corresponding_ontology_klass(filepath)
    is_distributed = Ontology.file_extensions_distributed.
      include?(File.extname(filepath))
    is_distributed ? DistributedOntology : SingleOntology
  end

  def create_version(ontology, commit_oid, ontology_version_options, changed_files)
    version = ontology.versions.build(
      { commit_oid: commit_oid,
        commit: repository.commit_for!(commit_oid,
                                       ontology_version_options.pusher),
        # We can't use the ontology's filepath bacause it might have changed
        basepath: File.basepath(ontology_version_options.filepath),
        file_extension: File.extname(ontology_version_options.filepath),
        fast_parse: ontology_version_options.fast_parse },
      { without_protection: true })
    version.do_not_parse! if ontology_version_options.do_not_parse
    version.files_to_parse_afterwards = files_to_parse(ontology, changed_files)
    version.save!
    ontology.ontology_version = version
    ontology.save!

    version
  end

  def applicable_for_priority?(commits_count, highest_change_file_count)
    (commits_count <= priority_settings.commits) &&
      (highest_change_file_count <= priority_settings.changed_files_per_commit)
  end

  def priority_settings
    @priority_settings ||= OpenStruct.new(Settings.git[:push_priority])
  end

  def schedule_batch_parsing(versions, priority_mode: false)
    grouped_versions = versions.compact.group_by(&:path)
    grouped_versions.each do |k,versions|
      optioned_versions = versions.map do |version|
        [version.id, {fast_parse: version.fast_parse}, 1]
      end
      if priority_mode
        OntologyParsingPriorityWorker.perform_async(optioned_versions)
      else
        OntologyParsingWorker.perform_async(optioned_versions)
      end
    end
  end

  # Files that import the current one must be parsed as well.
  def files_to_parse(ontology, changed_files)
    ontology.mapping_targets.map(&:path) - [*changed_files, ontology.path]
  end
end
