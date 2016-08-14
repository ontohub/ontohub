Before do
  redis = WrappingRedis::RedisWrapper.new
  redis.del redis.keys if redis.keys.any?
  Sidekiq::Worker.clear_all
end

Before('@require_accept_html') do
  Capybara.current_session.driver.header('Accept', 'text/html')
end
