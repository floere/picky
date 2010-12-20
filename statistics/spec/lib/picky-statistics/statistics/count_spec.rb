require 'spec_helper'

describe Statistics::Count do
  
  before(:each) do
    @stats = Statistics::Count.new :pattern1, :pattern2
  end
  
  describe 'to_s' do
    it 'is the count to_s' do
      @stats.to_s.should == "0"
    end
  end
  
end
