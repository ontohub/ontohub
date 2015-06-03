%w(localhost:8000).each do |uri|
  HetsInstance.create(name: uri, uri: "http://#{uri}")
end
