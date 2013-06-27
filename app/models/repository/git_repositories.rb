module Repository::GitRepositories
  extend ActiveSupport::Concern

  included do
    after_create  :git
    after_destroy :destroy_git
  end

  def git
    @git ||= GitRepository.new(local_path)
  end

  def local_path
    "#{Ontohub::Application.config.git_root}/#{id}"
  end

  def destroy_git
    FileUtils.rmtree local_path
  end

  def save_file(tmp_file, filepath, message, user)
    commit_oid = git.add_file({email: user[:email], name: user[:name]}, tmp_file, filepath, message)
    if(git.path_exists?(nil, filepath))
      clazz = filepath.ends_with?('.casl') ? DistributedOntology : SingleOntology

      o = clazz.new \
        iri:         "http://#{Settings.hostname}/#{path}/#{Ontology.filename_without_extension(filepath)}",
        name:        filepath.split('/')[-1].split(".")[0].capitalize,
        description: ''

      v = o.versions.build({ :commit_oid => commit_oid, :user => user }, { without_protection: true })

      o.repository = self
      o.save!
      o.ontology_version = v;
      o.save!
    else
      o = ontologies.find_by_path(filepath)
      v = o.versions.build({ :commit_oid => commit_oid, :user => user }, { without_protection: true })
      o.ontology_version = v
      o.save!
    end
    touch
  end

end
