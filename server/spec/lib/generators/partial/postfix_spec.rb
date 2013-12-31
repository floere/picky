require 'spec_helper'

describe Picky::Generators::Partial::Postfix do

  context 'default from' do
    let(:generator) { described_class.new }

    describe 'use_exact_for_partial?' do
      it 'is correct' do
        generator.use_exact_for_partial?.should be_falsy
      end
    end
    describe 'from' do
      it 'should return the right value' do
        generator.from.should == 1
      end
    end
    # describe 'generate_from' do
    #   it 'should generate the right index' do
    #     generator.generate_from(florian: [1], flavia: [2]).should == {
    #       florian: [1],
    #       floria:  [1],
    #       flori:   [1],
    #       flor:    [1],
    #       flo:     [1],
    #       fl:   [1, 2],
    #       f:    [1, 2],
    #       flavia:  [2],
    #       flavi:   [2],
    #       flav:    [2],
    #       fla:     [2]
    #     }
    #   end
    #   it "should be fast" do
    #     performance_of { generator.generate_from(florian: [1], flavia: [2]) }.should < 0.0001
    #   end
    #   it "should handle duplicate ids" do
    #     generator.generate_from(flo: [1], fla: [1]).should == {
    #       flo: [1],
    #       fl:  [1],
    #       f:   [1],
    #       fla: [1]
    #     }
    #   end
    # end
  end
  context 'specific negative from' do
    # describe 'negative from' do
    #   before(:each) do
    #     @generator = described_class.new from: -2
    #   end
    #   it 'should generate the right index' do
    #     @generator.generate_from(florian: [1], flavia: [2]).should == {
    #       florian: [1],
    #       floria:  [1],
    #       flavia:  [2],
    #       flavi:   [2]
    #     }
    #   end
    # end
    # context "large from" do
    #   before(:each) do
    #     @generator = described_class.new from: 10
    #   end
    #   describe 'generate_from' do
    #     it 'should generate the right index' do
    #       @generator.generate_from(florian: [1], :'01234567890' => [2] ).should == {
    #         :florian => [1],
    #         :'01234567890' => [2],
    #         :'0123456789' => [2]
    #       }
    #     end
    #   end
    # end
    # context 'specific positive from' do
    #   before(:each) do
    #     @generator = described_class.new from: 4
    #   end
    #   describe 'to' do
    #     it 'should return the right value' do
    #       @generator.to.should == -1
    #     end
    #   end
    #   describe 'from' do
    #     it 'should return the right value' do
    #       @generator.from.should == 4
    #     end
    #   end
    #   describe 'generate_from' do
    #     it 'should generate the right index' do
    #       @generator.generate_from( :florian => [1], :flavia => [2] ).should == {
    #         :florian => [1],
    #         :floria => [1],
    #         :flori => [1],
    #         :flor => [1],
    #         :flavia => [2],
    #         :flavi => [2],
    #         :flav => [2]
    #       }
    #     end
    #   end
    #   describe "a bigger example with disjunct symbols" do
    #     before(:each) do
    #       abc = ('A'..'Z').to_a + ('a'..'z').to_a
    #       @index = {}
    #       52.times do |i|
    #         @index[abc.join.to_sym] = [i]
    #         character = abc.shift
    #         abc << character
    #       end
    #     end
    #     it "should be fast" do
    #       performance_of { @generator.generate_from(@index) }.should < 0.008
    #     end
    #   end
    #   describe "a bigger example with almost identical symbols" do
    #     before(:each) do
    #       abc = ('A'..'Z').to_a + ('a'..'z').to_a
    #       @index = {}
    #       52.times do |i|
    #         @index[(abc.join + abc[i].to_s).to_sym] = [i]
    #       end
    #     end
    #     it "should be fast" do
    #       performance_of { @generator.generate_from(@index) }.should < 0.0045
    #     end
    #   end
    # end
  end

end