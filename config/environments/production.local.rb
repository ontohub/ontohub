Ontohub::Application.configure do
  config.log_level=:info
  config.consider_all_requests_local=true
  config.serve_static_assets = true
  config.assets.compress = false
  config.assets.digest = false
  config.assets.debug = true
end
