require 'spec_helper'

describe Generators::PartialGenerator do

  context 'integration' do
    it 'should generate the correct values with a given strategy' do
      generator = described_class.new :meier => [1], :maier => [2]
      
      generator.generate(Generators::Partial::Substring.new).should == {
        :meier => [1],
        :meie => [1],
        :mei => [1],
        :me => [1],
        :m => [1, 2],
        :maier => [2],
        :maie => [2],
        :mai => [2],
        :ma => [2]
      }
    end
    it 'should generate the correct values with a given specific strategy' do
      generator = described_class.new :meier => [1], :maier => [2]
      
      generator.generate(Generators::Partial::Substring.new(:from => 3)).should == {
        :meier => [1],
        :meie => [1],
        :mei => [1],
        :maier => [2],
        :maie => [2],
        :mai => [2]
      }
    end
  end

end