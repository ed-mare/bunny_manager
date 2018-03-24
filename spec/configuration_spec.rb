require 'spec_helper'

RSpec.describe BunnyManager::Configuration do

  let(:config) { BunnyManager::Configuration.new }
  let(:conn_configs) do
    {
      host: '111.222.333.444',
      port: 12345,
      vhost: '/foo',
      user: 'bar',
      pass: 'baz'
    }
  end
  let(:config_override) do
    BunnyManager::Configuration.new.tap do |c|
      c.pool_size = 10
      c.pool_timeout = 7
      c.connection_configs = conn_configs
      c.logger = 'xyz'
    end
  end

  describe '#pool_size' do
    it 'defaults to 5' do
      expect(config.pool_size).to eq(5)
    end
    it 'is configurable' do
      expect(config_override.pool_size).to eq(10)
    end
  end

  describe '#pool_timeout' do
    it 'defaults to 5' do
      expect(config.pool_timeout).to eq(5)
    end
    it 'is configurable' do
      expect(config_override.pool_timeout).to eq(7)
    end
  end

  describe '#connection_configs' do
    it 'defaults to empty hash' do
      expect(config.connection_configs).to eq(Hash.new)
    end
    it 'is configurable' do
      expect(config_override.connection_configs).to eq(conn_configs)
    end
  end

  describe '#logger' do
    it 'defaults to empty hash' do
      expect(config.logger).to be_instance_of(Logger)
    end
    it 'is configurable' do
      expect(config_override.logger).to eq('xyz')
    end
  end

end
