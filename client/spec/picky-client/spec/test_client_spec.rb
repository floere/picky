require 'spec_helper'

require 'rack'
require 'picky-client/spec'

describe Picky::TestClient do
  
  class TestApplication; end
  
  let(:client) { described_class.new(TestApplication, :path => '/some/path') }
  
  context 'search' do
    it 'does extract the hash' do
      TestApplication.stub! :call => [200, { 'Content-Type' => 'application/json' }, ['{"allocations":[["boooookies",0.0,1,[["title","hell","hell"]],[313]]],"offset":0,"duration":0.000584,"total":1}']]
      
      client.search('test').should == { :allocations => [['boooookies', 0.0, 1, [['title', 'hell', 'hell']], [313]]], :offset => 0, :duration => 0.000584, :total => 1 }
    end
    it 'does extend the result with convenience methods' do
      TestApplication.stub! :call => [200, { 'Content-Type' => 'application/json' }, ['{"allocations":[["boooookies",0.0,1,[["title","hell","hell"]],[313]]],"offset":0,"duration":0.000584,"total":1}']]
      
      client.search('test').total.should == 1
    end
  end
  
end