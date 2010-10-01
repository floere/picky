require 'spec_helper'

describe Picky::Serializer do

  describe "serialize-deserialize" do
    it "should serialize and deserialize certain values" do
      results = stub :results
      results.stub! :serialize => {}

      deserialized = Picky::Serializer.deserialize Picky::Serializer.serialize(results)

      deserialized.should == {}
    end
  end

  describe "serialize" do
    it "should serialize" do
      results = stub :results, :serialize => {
        :allocations => [[nil, nil, nil, [1,2,3,4,5,6,7,8]],
                         [nil, nil, nil, [9,10,11,12,13,14,15,16]],
                         [nil, nil, nil, [17,18,19,20,21,22,23]]],
        :offset => 123,
        :total => 12345,
        :duration => 0.12345
      }

      Picky::Serializer.serialize(results).should == "\x04\b{\t:\x10allocations[\b[\t000[\ri\x06i\ai\bi\ti\ni\vi\fi\r[\t000[\ri\x0Ei\x0Fi\x10i\x11i\x12i\x13i\x14i\x15[\t000[\fi\x16i\x17i\x18i\x19i\x1Ai\ei\x1C:\voffseti\x01{:\ntotali\x0290:\rdurationf\x0F0.12345\x00\xF2|"
    end
  end

  describe "deserialize" do
    it "should deserialize" do
      results = Picky::Serializer.deserialize "\x04\b{\t:\x10allocations[\b[\t000[\ri\x06i\ai\bi\ti\ni\vi\fi\r[\t000[\ri\x0Ei\x0Fi\x10i\x11i\x12i\x13i\x14i\x15[\t000[\fi\x16i\x17i\x18i\x19i\x1Ai\ei\x1C:\voffseti\x01{:\ntotali\x0290:\rdurationf\x0F0.12345\x00\xF2|"

      results.should be_kind_of(Hash)
    end
  end

end