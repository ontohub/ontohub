Sidekiq::Testing.disable! do
  %w(localhost:8000).each do |uri|
    HetsInstance.create(name: uri, uri: "http://#{uri}", state: 'free', queue_size: 0)
  end
end
