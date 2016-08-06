require "sidekiq"
require "sidekiq/retry_exceptions/version"
require "sidekiq/retry_exceptions/server/middleware"

Sidekiq.configure_server do |config|
  require "sidekiq/middleware/server/retry_jobs"
  require "sidekiq/retry_exceptions/server/middleware"

  config.server_middleware do |chain|
    chain.insert_before Sidekiq::Middleware::Server::RetryJobs,
      Sidekiq::RetryExceptions::Server::Middleware
    chain.remove Sidekiq::Middleware::Server::RetryJobs
  end
end
