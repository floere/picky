require 'spec_helper'

describe Statistics::LogfileReader do
  
  before(:each) do
    @reader = Statistics::LogfileReader.new 'spec/data/search.log'
  end
  
  describe 'full' do
    it 'is set to have the right keys' do
      @reader.full.should have_key(:total)
      @reader.full.should have_key(:quick)
      @reader.full.should have_key(:long_running)
      @reader.full.should have_key(:very_long_running)
      @reader.full.should have_key(:offset)
      
      @reader.full[:totals].should have_key(0)
      @reader.full[:totals].should have_key(1)
      @reader.full[:totals].should have_key(2)
      @reader.full[:totals].should have_key(3)
      @reader.full[:totals].should have_key(:'4+')
      @reader.full[:totals].should have_key(:'100+')
      @reader.full[:totals].should have_key(:'1000+')
      @reader.full[:totals].should have_key(:cloud)
    end
  end
  describe 'live' do
    it 'is set to a specific Hash at first' do
      @reader.live.should have_key(:total)
    end
  end
  
  describe 'since_last' do
    it 'returns a specific JSON result' do
      @reader.since_last.to_json.should == '{"full":{"total":"22","totals":{"0":"1","1":"1","2":"1","3":"1","4+":"6","100+":"2","1000+":"10","cloud":"3"},"quick":"16","long_running":"2","very_long_running":"2","offset":"5"},"live":{"total":"1"}}'
    end
    it 'is at a specific line after reading the log file' do
      @reader.since_last
      
      @reader.last_offset.should == 23
    end
  end
  
end