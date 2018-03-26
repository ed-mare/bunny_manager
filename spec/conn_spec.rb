require 'spec_helper'

RSpec.describe BunnyManager::Conn do
  let(:conn) { BunnyManager::Conn.create }

  describe '.create' do
    it 'returns an instance of Bunny::Session' do
      expect(conn).to be_an_instance_of(BunnyMock::Session)
    end
    it 'is connected' do
      expect(conn.status).to eq(:connected)
      expect(conn.connected?).to eq(true)
    end
  end
end
