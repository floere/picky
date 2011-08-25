require 'spec_helper'

describe Picky::Backends::Redis do

  before(:each) do
    @backend = described_class.new
    
    @inverted      = @backend.inverted
    @weights       = @backend.weights
    @similarity    = @backend.similarity
    @configuration = @backend.configuration
  end
  
  describe "ids" do
    before(:each) do
      @combination1 = stub :combination1, :identifier => 'cat1'
      @combination2 = stub :combination2, :identifier => 'cat2'
      @combination3 = stub :combination3, :identifier => 'cat3'
      @combinations = [@combination1, @combination2, @combination3]
    end
    it 'calls the redis client correctly' do
      # TODO
    end
  end
  
end