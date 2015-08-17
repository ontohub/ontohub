if Rails.env.production?
  RakeHelper::Hets.create_instances
else
  Sidekiq::Testing.disable! do
    RakeHelper::Hets.create_instances
  end
end
