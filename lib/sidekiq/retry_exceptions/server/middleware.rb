require "sidekiq/middleware/server/retry_jobs"

module Sidekiq
  RetryException = Class.new(StandardError)
  module RetryExceptions
    module Server
      class Middleware < Sidekiq::Middleware::Server::RetryJobs
        def attempt_retry(worker, msg, queue, exception)
          begin
            super
          rescue Sidekiq::RetryException => exception
          end
        end
      end
    end
  end
end
