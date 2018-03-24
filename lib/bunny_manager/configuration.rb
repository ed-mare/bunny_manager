module BunnyManager
  # == Gem Configurations
  #
  # === Example:
  #
  #   # in config/initializers/bunny_manager.rb
  #
  #   BunnyManager.configure do |c|
  #     c.pool_size = 10
  #     c.connection_configs = {
  #         host: ENV["AMQP_HOST"],
  #         port: ENV["AMQP_PORT"],
  #         ssl: false,
  #         vhost: ENV["AMQP_VHOST"],
  #         user: ENV["AMQP_USER"],
  #         pass: ENV["AMQP_PASS"]
  #     }
  #     c.logger = Rails.logger
  #   end
  #
  class Configuration
    # @return [Integer]. Pool size. Defaults to ActiveRecord::Base.connection_config if
    # defined, otherwise 5.
    attr_accessor :pool_size

    # @return [Integer]. Pool timeout in seconds. Amount of time to wait for a connection
    # if none currently available; defaults to 5 seconds.
    attr_accessor :pool_timeout

    # @return [Logger] Defaults to Logger.new(STDOUT).
    attr_accessor :logger

    # Hash. Bunny::Session.initialize hash. Defaults to empty hash.
    # See http://www.rubydoc.info/github/ruby-amqp/bunny/Bunny/Session.
    attr_accessor :connection_configs

    def initialize
      set_defaults
    end

    protected

    def set_defaults
      @connection_configs = {}
      @logger = Logger.new(STDOUT)
      @pool_size = default_pool_size
      @pool_timeout = 5
    end

    def default_pool_size
      active_record_pool_size || 5
    end

    def active_record_pool_size
      if defined?(ActiveRecord) && ActiveRecord::Base.respond_to?(:connection_config)
        ActiveRecord::Base.connection_config[:pool]
      end
    end
  end
end
