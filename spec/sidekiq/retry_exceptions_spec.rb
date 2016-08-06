require "spec_helper"

class RetryExceptionWorker
  include Sidekiq::Worker

  def perform
    raise Sidekiq::RetryException.new("Try again later...")
  end
end

class RuntimeExceptionWorker
  include Sidekiq::Worker

  def perform
    raise "A more serious error!"
  end
end

describe Sidekiq::RetryExceptions do

  before(:each) do
    Sidekiq.redis {|c| c.flushdb }
  end

  context "when RetryExceptionWorker raises a RetryException" do
    it "should not be noisy" do
      Sidekiq::Testing.inline! do
        RetryExceptionWorker.perform_async
      end
    end

    it "should remain in the queue to retry" do
      Sidekiq::Testing.inline! do
        RetryExceptionWorker.perform_async
        expect(Sidekiq::RetrySet.new.size).to eq(1)
      end
    end
  end

  context "When RuntimeExceptionWorker raises a RuntimeError" do
    it "should be noisy" do
      Sidekiq::Testing.inline! do
        expect{ RuntimeExceptionWorker.perform_async }.to(
          raise_exception(RuntimeError, /serious error/))
      end
    end

    it "should remain in the queue to retry" do
      Sidekiq::Testing.inline! do
        begin
          RuntimeExceptionWorker.perform_async
        rescue
        ensure
          expect(Sidekiq::RetrySet.new.size).to eq(1)
        end
      end
    end
  end
end
