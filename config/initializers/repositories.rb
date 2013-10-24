
if Rails.env.test?
  Ontohub::Application.config.git_root = "#{Rails.root}/tmp/repositories"
  Ontohub::Application.config.git_working_copies_root = "#{Rails.root}/tmp/repositories_working_copies"
else
  Ontohub::Application.config.git_root = "#{Rails.root}/public/repositories"
  Ontohub::Application.config.git_working_copies_root = "#{Rails.root}/data/repositories_working_copies"
  Ontohub::Application.config.git_home = File.join(Rails.root, 'tmp', 'git')
  Ontohub::Application.config.git_user = %x[whoami]
  Ontohub::Application.config.git_group = nil
  if Rails.env.production?
    Ontohub::Application.config.git_home = "/srv/git/"
    Ontohub::Application.config.git_user = "git"
    Ontohub::Application.config.git_group = "git"
  end
end

Ontohub::Application.config.max_read_filesize = 512 * 1024
