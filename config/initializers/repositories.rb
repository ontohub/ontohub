
if Rails.env.test?
  Ontohub::Application.config.git_root = "#{Rails.root}/tmp/repositories"
else
  Ontohub::Application.config.git_root = "#{Rails.root}/public/repositories"
end

Ontohub::Application.config.max_read_filesize = 512 * 1024
