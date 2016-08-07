# Sidekiq Retry Exceptions

[![Build Status](https://travis-ci.org/grepme/sidekiq-retry_exceptions.svg?branch=master)](https://travis-ci.org/grepme/sidekiq-retry_exceptions)

Retry jobs without generating unnecessary noise in your bug tracker, New Relic, PagerDuty, etc.

This gem subclasses RetryJobs, the default Sidekiq middleware.

# Why Was This Made?

Imagine being on call for your web application, you are the first line of defense.
You can expect to be woken up by your phone or pager late at night for a variety of incidents.

One such night, at 3 A.M, I was awoken to the blaring theme song of Scott Pilgrim.
No, this was not some noisy neighbours, only PagerDuty overriding my phone's silent setting
because the error rate on our background workers had sharply risen to 20%.

The first place I checked was the Sidekiq retries queue to examine why
so many jobs were failing in the first place. I was greeted with a web hook exception:
did not receive 2xx status code from server.

This is when I realized I was at the mercy of our clients' servers. They'd eventually
get the data, retrying every hour for 48 hours, but not before I lost sleep over it.

I wanted the retry functionality of sidekiq without the noise of an exception that
was out of my control.

This gem does violate one of Sidekiq's best practices:

> Let Sidekiq catch errors raised by your jobs. Sidekiq's built-in retry mechanism will catch those exceptions and retry the jobs regularly. The error service will notify you of the exception. You fix the bug, deploy the fix and Sidekiq will retry your job successfully.
> https://github.com/mperham/sidekiq/wiki/Error-Handling

The problem with this is that I had no control over what an external API consumer
will return as a status code. There was no bug to fix on my end.

I'd suggest checking if your incident reporting can filter out expected errors
like the one above before using this gem. Make sure they are 100% unavoidable
and you aren't discounting legitimate issues in your code.

The best practice in my mind is one that you won't lose sleep over.

## Installation

Add this line to your application's Gemfile after the sidekiq gem:

```ruby
gem 'sidekiq-retry_exceptions'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-retry_exceptions

## Usage

A mock example for your worker:

```ruby
def perform(args)
  if service_unavailable?
    raise Sidekiq::RetryException.new("Try again later...")
  end
end
```

You can also subclass Sidekiq::RetryException for a more descriptive exception.
Good practice is to keep these exceptions to only your worker, make sure
these exceptions are not deep in your model logic.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/grepme/sidekiq-retry_exceptions.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
