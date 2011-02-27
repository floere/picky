require 'spec_helper'

describe Internals::Query::Qualifiers do
  
  before(:each) do
    described_class.instance << Internals::Query::Qualifier.new(:test1, ['t1', 'tt1', 'ttt1'])
    described_class.instance << Internals::Query::Qualifier.new(:test2, [:t2, :tt2, :ttt2])
    described_class.instance << Internals::Query::Qualifier.new(:test3, [:t3, :tt3, :ttt3])
    described_class.instance.prepare
  end
  
  def self.it_should_normalize(qualifier, expected)
    it "should map #{qualifier} to #{expected}" do
      described_class.instance.normalize(qualifier).should == expected
    end
  end

  describe "mapping" do
    it_should_normalize :t1,   :test1
    it_should_normalize :tt1,  :test1
    it_should_normalize :ttt1, :test1
    
    it_should_normalize :t2,   :test2
    it_should_normalize :tt2,  :test2
    it_should_normalize :ttt2, :test2
    
    it_should_normalize :t3,   :test3
    it_should_normalize :tt3,  :test3
    it_should_normalize :ttt3, :test3
  end
end