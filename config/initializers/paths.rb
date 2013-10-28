
Ontohub::Application.configure do |app|
  c = app.config

  if Rails.env.test?
    c.data_root = Rails.root.join('tmp','data')
  else
    c.data_root = Rails.root.join('data')
  end
  
  c.git_root                = c.data_root.join('repositories')
  c.git_working_copies_root = c.data_root.join('working_copies')
  c.max_read_filesize       = 512 * 1024

  if (settings = Settings.git).try(:user)
    c.git_user  = settings.user
    c.git_group = settings.group
    c.git_home  = File.expand_path("~#{c.git_user}")
  else
    c.git_user  = nil
    c.git_group = nil
    c.git_home  = Rails.root.join('tmp','git')
  end
end
