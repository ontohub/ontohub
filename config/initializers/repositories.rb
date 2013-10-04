
if Rails.env.test?
  Ontohub::Application.config.git_root = "#{Rails.root}/tmp/repositories"
  Ontohub::Application.config.git_working_copies_root = "#{Rails.root}/tmp/repositories_working_copies"
else
  Ontohub::Application.config.git_root = "#{Rails.root}/public/repositories"
  Ontohub::Application.config.git_working_copies_root = "#{Rails.root}/data/repositories_working_copies"
end

Ontohub::Application.config.max_read_filesize = 512 * 1024
