require 'spec_helper'

describe Cacher::Partial::Subtoken do
  
  context 'default down_to' do
    before(:each) do
      @cacher = Cacher::Partial::Subtoken.new
    end
    describe 'down_to' do
      it 'should return the right value' do
        @cacher.down_to.should == 1
      end
    end
    describe 'generate_from' do
      it 'should generate the right index' do
        @cacher.generate_from( :florian => [1], :flavia => [2] ).should == {
          :florian => [1],
          :floria => [1],
          :flori => [1],
          :flor => [1],
          :flo => [1],
          :fl => [1, 2],
          :f => [1, 2], 
          :flavia => [2],
          :flavi => [2],
          :flav => [2],
          :fla => [2]
        }
      end
      it "should be fast" do
        Benchmark.realtime { @cacher.generate_from( :florian => [1], :flavia => [2] ) }.should < 0.0001
      end
      it "should handle duplicate ids" do
        @cacher.generate_from( :flo => [1], :fla => [1] ).should == {
          :flo => [1],
          :fl => [1],
          :f => [1],
          :fla => [1]
        }
      end
    end
  end
  context 'down_to set' do
    describe 'negative down_to' do
      before(:each) do
        @cacher = Cacher::Partial::Subtoken.new :down_to => -2
      end
      it 'should generate the right index' do
        @cacher.generate_from( :florian => [1], :flavia => [2] ).should == {
          :florian => [1],
          :floria => [1],
          :flavia => [2],
          :flavi => [2]
        }
      end
    end
    context "large down_to" do
      before(:each) do
        @cacher = Cacher::Partial::Subtoken.new :down_to => 10
      end
      describe 'generate_from' do
        it 'should generate the right index' do
          @cacher.generate_from( :florian => [1], :'01234567890' => [2] ).should == {
            :florian => [1],
            :'01234567890' => [2],
            :'0123456789' => [2]
          }
        end
      end
    end
    context 'default starting_at' do
      before(:each) do
        @cacher = Cacher::Partial::Subtoken.new :down_to => 4
      end
      describe 'starting_at' do
        it 'should return the right value' do
          @cacher.starting_at.should == -1
        end
      end
      describe 'down_to' do
        it 'should return the right value' do
          @cacher.down_to.should == 4
        end
      end
      describe 'generate_from' do
        it 'should generate the right index' do
          @cacher.generate_from( :florian => [1], :flavia => [2] ).should == {
            :florian => [1],
            :floria => [1],
            :flori => [1],
            :flor => [1],
            :flavia => [2],
            :flavi => [2],
            :flav => [2]
          }
        end
      end
      describe "a bigger example with disjunct symbols" do
        before(:each) do
          abc = ('A'..'Z').to_a + ('a'..'z').to_a
          @index = {}
          52.times do |i|
            @index[abc.join.to_sym] = [i]
            character = abc.shift
            abc << character
          end
        end
        it "should be fast" do
          Benchmark.realtime { @cacher.generate_from(@index) }.should < 0.005
        end
      end
      describe "a bigger example with almost identical symbols" do
        before(:each) do
          abc = ('A'..'Z').to_a + ('a'..'z').to_a
          @index = {}
          52.times do |i|
            @index[(abc.join + abc[i].to_s).to_sym] = [i]
          end
        end
        it "should be fast" do
          Benchmark.realtime { @cacher.generate_from(@index) }.should < 0.003
        end
      end
    end
    context 'starting_at -1' do
      before(:each) do
        @cacher = Cacher::Partial::Subtoken.new :down_to => 4, :starting_at => -2
      end
      describe 'starting_at' do
        it 'should return the right value' do
          @cacher.starting_at.should == -2
        end
      end
      describe 'down_to' do
        it 'should return the right value' do
          @cacher.down_to.should == 4
        end
      end
      describe 'generate_from' do
        it 'should generate the right index' do
          @cacher.generate_from( :florian => [1], :flavia => [2] ).should == {
            :floria => [1],
            :flori => [1],
            :flor => [1],
            :flavi => [2],
            :flav => [2]
          }
        end
      end
    end
  end
  
end