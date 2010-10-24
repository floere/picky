require 'spec_helper'

describe Results::Live do
  
  it "is the right subclass" do
    Results::Live.should < Results::Base
  end
  
  it "logs correctly" do
    Time.stub! :now => Time.parse('2010-10-25 01:25:07')
    
    Results::Live.new.to_log('some query').should == '.|2010-10-25 01:25:07|0.000000|some query                                        |       0|   0| 0|'
  end
  
end