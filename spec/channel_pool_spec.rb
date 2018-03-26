require 'spec_helper'

RSpec.describe BunnyManager::Conn do
  let(:conn) { BunnyManager::Conn.create }
  let(:pool) { BunnyManager::ChannelPool.create(conn) }

  describe '.create(connection)' do
    it 'returns a connection pool of channels' do
      expect(pool).to be_an_instance_of(ConnectionPool)
    end
    it 'is a pool of channels' do
      pool.with do |channel|
        expect(channel).to be_an_instance_of(BunnyMock::Channel)
      end
    end
  end
end
