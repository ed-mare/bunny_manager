# BunnyManager

This gem provides a way to manage Bunny channels with a connection pool. It was inspired by the article ["Rabbits, Bunnies and Threads"](https://wework.github.io/ruby/rails/bunny/rabbitmq/threads/concurrency/puma/errors/2015/11/12/bunny-threads/).

Bunny states in its [concurrency documentation](http://rubybunny.info/articles/concurrency.html):

> Connections in Bunny will synchronize writes both for messages and at the socket level. This means that publishing on a shared connection from multiple threads is safe but only if every publishing thread uses a separate channel.

> Channels must not be shared between threads. When client publishes a message, at least 2 (typically 3) frames are sent on the wire:

> - AMQP 0.9.1 method, basic.publish
> - Message metadata
> - Message payload

> This means that without synchronization on, publishing from multiple threads on a shared channel may result in frames being sent to RabbitMQ out of order.

---

This is a WIP. Known to work with Ruby 2.3.x.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bunny_manager', git: 'https://github.com/ed-mare/bunny_manager.git'
```

And then execute:
```bash
$ bundle
```

If using Passenger docker image, this works:

```shell
# Dockerfile
RUN git clone https://github.com/ed-mare/bunny_manager.git \
    && cd bunny_manager \
    && gem build bunny_manager.gemspec \
    && gem install bunny_manager-0.1.0.gem
```

## Usage

In an initializer...

```ruby
require 'bunny_manager'

# 1) Configure

BunnyManager.configure do |c|
  # Maximum number of channels in pool
  c.pool_size = 10

  # Timeout if channel can't be fetched in 10 seconds
  c.pool_timeout = 10

  # Connection configs
  c.connection_configs = {
    automatic_recovery: true,
    host: ENV["AMQP_HOST"],
    port: ENV["AMQP_PORT"] || 5672,
    vhost: ENV["AMQP_VHOST"] || "/",
    user: ENV["AMQP_USER"] || "guest",
    pass: ENV["AMQP_PASS"] || "guest"
  }

  # Log with my app's logger
  c.logger = Rails.logger
end

# 2) Connect

def connect_bunny
  BunnyManager.connect
rescue => ex
  # let it retry connecting later if it can't at startup
  # log error    
end

# If using threaded server...
connect_bunny

# Otherwise, if using forked server like Passenger...

if defined?(PhusionPassenger)
 # https://www.phusionpassenger.com/library/indepth/ruby/spawn_methods/
 PhusionPassenger.on_event(:starting_worker_process) do |forked|
   if forked
     BunnyManager.disconnect
     connect_bunny
   end
 end
 PhusionPassenger.on_event(:stopping_worker_process) do
   BunnyManager.disconnect # optional
 end
end
```

In your code...

```ruby
BunnyManager.channel do |channel|
  xchange = channel.topic("emails.exchange", durable: true)
  # ...
end

Thread.new do
  # setting timeout to 3 seconds for only this invocation.
  BunnyManager.channel(timeout: 3) do |channel|
    xchange = channel.topic("indexing.exchange", durable: true)
    # ...
  end
end
```

## Development

1) Build the docker image. **Re-build the image anytime gem specs are modified.**

```shell
docker-compose build
```

2) Start docker image with an interactive bash shell:

```shell
docker-compose run --rm gem
```

3) Once in bash session, code, run tests, start console, etc.

```shell
# run console with gem loaded
bundle console

# run tests
rspec

# run rubocop
rubocop

# run bundler-audit
bundler-audit

# generate rdoc
rdoc --main 'README.md' --exclude 'spec' --exclude 'bin' --exclude 'Gemfile' --exclude 'Dockerfile' --exclude 'Rakefile'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ed-mare/bunny_manager. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## TODO

- Conn.create - rescue from all exceptions?
- Better to test with a real RabbitMQ instance?

## Code of Conduct

Everyone interacting in the BunnyManager project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ed-mare/bunny_manager/blob/master/CODE_OF_CONDUCT.md).
