require 'logger'
require 'bunny'
require 'connection_pool'

require 'bunny_manager/version'
require 'bunny_manager/configuration'

module BunnyManager
  class << self
    attr_writer :configuration

    # Configurations for the module. See BunnyManager::Configuration for details.
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    # Convenience method. The logger specified in BunnyManager::Configuration.
    # @return [Logger]
    def logger
      BunnyManager.configuration.logger
    end

    # Convenience method. The connection_configs specified in BunnyManager::Configuration.
    # @return [Hash] BunnyManager.configuration.connection_configs
    def connection_configs
      BunnyManager.configuration.connection_configs
    end

    # Creates a Bunny session and a connection pool of channels. When Bunny detects
    # TCP connection failure, it will try to reconnect, by default, every 5
    # seconds (configurable in session configs). It performs automatic recovery which
    # consists of the following steps:
    #
    #   - Re-open channels
    #   - For each channel, re-declare exchanges (except for predefined ones)
    #   - For each channel, re-declare queues
    #   - For each queue, recover all bindings
    #   - For each queue, recover all consumers
    #
    # @see http://rubybunny.info/articles/error_handling.html
    #
    # @return [Bunny::Session] Bunny::Session instance.
    def connect
      @connection = BunnyManager::Conn.create
      @channel_pool = BunnyManager::ChannelPool.create(@connection)
      @connection
    end

    # Returns true if connection object is instantiated.
    # @return [Boolean] true if an instance of Bunny::Session.
    def connected?
      @connection.respond_to?(:connected?) &&
         @connection.connected?
    end

    # Shuts down connection pool of channels. Closes connection to RabbitMQ.
    def disconnect
      if @channel_pool.respond_to?(:shutdown)
        @channel_pool.shutdown do |channel|
          begin
            channel.close
          rescue StandardError => ex
            logger.warn("BunnyManager is failing to close channels: #{ex.message}")
          end
        end
      end

      begin
        @connection.close if connected?
      rescue StandardError => ex
        logger.warn("BunnyManager is failing to close the connection: #{ex.message}")
      end
    end

    # Fetch a channel from the channel pool. Can raise Bunny::Exception if there is a
    # connection or channel error. Channels are lazily created.
    #
    # @example
    #
    #   BunnyManager.channel do |channel|
    #     xchange = channel.topic("emails.exchange", durable: true)
    #   end
    #
    # @example Overriding the global timeout for a single invocation
    #
    #   BunnyManager.channel(timeout: 2) do |channel|
    #     xchange = channel.topic("emails.exchange", durable: true)
    #   end
    #
    # @param [Hash] Connection pool options - {with: <seconds>} sets timeout for a
    # single invocation.
    # @param [block] A block using the channel.
    def channel(options = {})
      raise ArgumentError, 'requires a block' unless block_given?
      @channel_pool.with(options) do |channel|
        yield channel
      end
    end
  end

  # Creates a physical connection to RabbitMQ.
  class Conn
    class << self
      # Creates a Bunny session.
      # @return [Bunny::Session] Bunny::Session instance.
      def create
        client_class.new(BunnyManager.connection_configs).tap(&:start)
      end
      protected
      # For stubbing.
      def client_class
        Bunny
      end
    end
  end

  # Creates RabbitMQ channel pool.
  class ChannelPool
    class << self
      # Creates a connection pool of RabbitMQ channels.
      #
      # @param [Bunny::Session] Bunny session.
      # @return [ConnectionPool] ConnectionPool of Bunny::Channel.
      def create(connection)
        ConnectionPool.new(size: BunnyManager.configuration.pool_size,
                           timeout: BunnyManager.configuration.pool_timeout) do
          connection.create_channel
        end
      end
    end
  end
end
