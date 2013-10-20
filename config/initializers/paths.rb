
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
end
