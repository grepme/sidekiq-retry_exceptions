$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "pry"
require "sidekiq"
require 'sidekiq/testing'
require "sidekiq/retry_exceptions"
require 'sidekiq/redis_connection'

Sidekiq::Testing.inline!

Sidekiq::Testing.server_middleware do |chain|
  chain.insert_before Sidekiq::Middleware::Server::RetryJobs,
    Sidekiq::RetryExceptions::Server::Middleware
  chain.remove Sidekiq::Middleware::Server::RetryJobs
end

REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost/15'
REDIS = Sidekiq::RedisConnection.create(:url => REDIS_URL, :namespace => 'sidekiq-retry_exceptions')

Sidekiq.configure_client do |config|
  config.redis = { :url => REDIS_URL, :namespace => 'sidekiq-retry_exceptions' }
end
