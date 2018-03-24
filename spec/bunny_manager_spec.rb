require 'spec_helper'

RSpec.describe BunnyManager do

  it 'has a version number' do
    expect(BunnyManager::VERSION).not_to be nil
  end

  describe '.configuration' do
    it 'returns an instance of BunnyManager::Configuration' do
      expect(BunnyManager.configuration).to be_instance_of(BunnyManager::Configuration)
    end
  end

  describe '.configure' do
    it 'provides a way to set configurations with a block' do
      BunnyManager.configure do |c|
        c.pool_size = 100
      end
      expect(BunnyManager.configuration.pool_size).to eq(100)
    end
  end

  describe '.logger' do
    it 'is a convenience method to the Configuration logger' do
      expect(BunnyManager.logger).to eq(BunnyManager.configuration.logger)
    end
  end

  describe '.connection_configs' do
    it 'is a convenience method to the Configuration connection_configs' do
      expect(BunnyManager.connection_configs).to eq(BunnyManager.configuration.connection_configs)
    end
  end

  describe '.connect' do
    it 'creates a Bunny session instance' do
      expect(BunnyManager.connect).to respond_to(:close)
    end
    # TODO: test configs? Mock class doesn't include connfigs.
    it 'creates a connection pool of channels' do
      BunnyManager.connect
      expect(BunnyManager.instance_variable_get(:@channel_pool)).to be_an_instance_of(ConnectionPool)
    end
  end

  describe '.connected?' do
    it 'is true when connected to RabbitMQ' do
      BunnyManager.connect
      expect(BunnyManager.connected?).to eq(true)
    end
    it 'is false when not connected to RabbitMQ' do
      BunnyManager.disconnect
      expect(BunnyManager.connected?).to eq(false)
    end
  end

  describe '.disconnect' do
    before(:each) do
      BunnyManager::Configuration.new.tap do |c|
        c.pool_size = 2
      end
    end
    it 'disconnects the connection to RabbitMQ' do
      BunnyManager.connect
      expect(BunnyManager.connected?).to eq(true)

      BunnyManager.disconnect
      expect(BunnyManager.connected?).to eq(false)
    end
    it 'shuts down each channel in the channel pool' do
      BunnyManager.connect
      BunnyManager.channel do |channel|
        xchange = channel.topic("emails.exchange", durable: true)
      end

      pool = BunnyManager.instance_variable_get(:@channel_pool)
      pool_que = pool.instance_variable_get(:@available).instance_variable_get(:@que)

      expect(pool_que.size).to eq(1)
      BunnyManager.disconnect
      expect(pool_que.size).to eq(0)
    end
  end

end
