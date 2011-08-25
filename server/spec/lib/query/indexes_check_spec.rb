require 'spec_helper'

describe Picky::Query::IndexesCheck do

  describe 'check_backend_types' do
    before(:each) do
      @redis  = stub :redis,  :backend => Picky::Backends::Redis.new
      @memory = stub :memory, :backend => Picky::Backends::Memory.new
    end
    it 'does not raise on the same type' do
      described_class.check_backend_types [@redis, @redis]
    end
    it 'raises on multiple types' do
      expect do
        described_class.check_backend_types [@redis, @memory]
      end.to raise_error(Picky::Query::DifferentTypesError)
    end
    it 'raises with the right message on multiple types' do
      expect do
        described_class.check_backend_types [@redis, @memory]
      end.to raise_error("Currently it isn't possible to mix Indexes with backends Picky::Backends::Redis and Picky::Backends::Memory in the same Search instance.")
    end
  end
  
end