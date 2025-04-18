require 'spec_helper'

describe Picky::Generators::Partial::Infix do

  context 'default min' do
    let(:generator) { described_class.new }

    describe 'use_exact_for_partial?' do
      it 'returns false' do
        described_class.new.use_exact_for_partial?.should == false
      end
    end
    describe 'min' do
      it 'should return the right value' do
        generator.min.should == 1
      end
    end
    # describe 'generate_from' do
    #   it 'should generate the right index' do
    #     generator.generate_from(florian: [1], flavia: [2]).should == {
    #       florian: [1],
    #       floria:  [1],
    #       lorian:  [1],
    #       flori:   [1],
    #       loria:   [1],
    #       orian:   [1],
    #       flor:    [1],
    #       lori:    [1],
    #       oria:    [1],
    #       rian:    [1],
    #       flo:     [1],
    #       lor:     [1],
    #       ori:     [1],
    #       ria:     [1],
    #       ian:     [1],
    #       fl:   [1, 2],
    #       lo:      [1],
    #       or:      [1],
    #       ri:      [1],
    #       ia:   [1, 2],
    #       an:      [1],
    #       f:    [1, 2],
    #       l:    [1, 2],
    #       o:       [1],
    #       r:       [1],
    #       i:    [1, 2],
    #       a:    [1, 2],
    #       n:       [1],
    #       flavia:  [2],
    #       flavi:   [2],
    #       lavia:   [2],
    #       flav:    [2],
    #       lavi:    [2],
    #       avia:    [2],
    #       fla:     [2],
    #       lav:     [2],
    #       avi:     [2],
    #       via:     [2],
    #       la:      [2],
    #       av:      [2],
    #       vi:      [2],
    #       v:       [2]
    #     }
    #   end
    #   it "should be fast" do
    #     performance_of { generator.generate_from(florian: [1], flavia: [2]) }.should < 0.0001
    #   end
    #   it "should handle duplicate ids" do
    #     generator.generate_from(flo: [1], fla: [1]).should == {
    #       flo: [1],
    #       fl:  [1],
    #       lo:  [1],
    #       f:   [1],
    #       l:   [1],
    #       o:   [1],
    #       a:   [1],
    #       fla: [1],
    #       la:  [1],
    #     }
    #   end
    # end
  end
  context 'from set' do
    # describe 'negative min' do
    #   before(:each) do
    #     @generator = described_class.new min: -2
    #   end
    #   it 'should generate the right index' do
    #     @generator.generate_from(florian: [1], flavia: [2]).should == {
    #       :florian => [1],
    #       :floria  => [1],
    #       :lorian  => [1],
    #       :flavia  => [2],
    #       :flavi   => [2],
    #       :lavia   => [2]
    #     }
    #   end
    # end
    context 'large min' do
      before(:each) do
        @generator = described_class.new min: 10
      end
      # describe 'generate_from' do
      #   it 'should generate the right index' do
      #     @generator.generate_from(florian: [1], :'01234567890' => [2]).should == {
      #       :'01234567890' => [2],
      #       :'0123456789' => [2],
      #       :'1234567890' => [2]
      #     }
      #   end
      # end
    end
    context 'default max' do
      before(:each) do
        @generator = described_class.new min: 4
      end
      describe 'max' do
        it 'should return the right value' do
          @generator.max.should == -1
        end
      end
      describe 'min' do
        it 'should return the right value' do
          @generator.min.should == 4
        end
      end
      # describe 'generate_from' do
      #   it 'should generate the right index' do
      #     @generator.generate_from( :florian => [1], :flavia => [2] ).should == {
      #       :florian => [1],
      #       :floria  => [1],
      #       :lorian  => [1],
      #       :flori   => [1],
      #       :loria   => [1],
      #       :orian   => [1],
      #       :flor    => [1],
      #       :lori    => [1],
      #       :oria    => [1],
      #       :rian    => [1],
      #       :flavia  => [2],
      #       :flavi   => [2],
      #       :lavia   => [2],
      #       :flav    => [2],
      #       :lavi    => [2],
      #       :avia    => [2]
      #     }
      #   end
      # end
      # describe "a bigger example with disjunct symbols" do
      #   before(:each) do
      #     abc = ('A'..'Z').to_a + ('a'..'z').to_a
      #     @index = {}
      #     52.times do |i|
      #       @index[abc.join.to_sym] = [i]
      #       character = abc.shift
      #       abc << character
      #     end
      #   end
      #   it "should be fast" do
      #     performance_of { @generator.generate_from(@index) }.should < 0.07
      #   end
      # end
      # describe "a bigger example with almost identical symbols" do
      #   before(:each) do
      #     abc = ('A'..'Z').to_a + ('a'..'z').to_a
      #     @index = {}
      #     52.times do |i|
      #       @index[(abc.join + abc[i].to_s).to_sym] = [i]
      #     end
      #   end
      #   it "should be fast" do
      #     performance_of { @generator.generate_from(@index) }.should < 0.07
      #   end
      # end
    end
    context 'to set' do
      before(:each) do
        @generator = described_class.new min: 4, max: -2
      end
      describe 'max' do
        it 'should return the right value' do
          @generator.max.should == -2
        end
      end
      describe 'min' do
        it 'should return the right value' do
          @generator.min.should == 4
        end
      end
      # describe 'generate_from' do
      #   it 'should generate the right index' do
      #     @generator.generate_from( :florian => [1], :flavia => [2] ).should == {
      #       :floria => [1],
      #       :lorian => [1],
      #       :flori  => [1],
      #       :loria  => [1],
      #       :orian  => [1],
      #       :flor   => [1],
      #       :lori   => [1],
      #       :oria   => [1],
      #       :rian   => [1],
      #       :flavi  => [2],
      #       :lavia  => [2],
      #       :flav   => [2],
      #       :lavi   => [2],
      #       :avia   => [2]
      #     }
      #   end
      # end
    end
    context 'min/max set' do
      before(:each) do
        @generator = described_class.new min: 4, max: 0
      end
      describe 'max' do
        it 'should return the right value' do
          @generator.max.should == 0
        end
      end
      describe 'min' do
        it 'should return the right value' do
          @generator.min.should == 4
        end
      end
      # describe 'generate_from' do
      #   it 'should generate the right index' do
      #     @generator.generate_from( :florian => [1], :flavia => [2] ).should == {}
      #   end
      # end
    end
  end

end
