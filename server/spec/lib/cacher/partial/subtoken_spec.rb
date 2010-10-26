require 'spec_helper'

describe Cacher::Partial::Substring do
  
  context 'default from' do
    before(:each) do
      @cacher = Cacher::Partial::Substring.new
    end
    describe 'from' do
      it 'should return the right value' do
        @cacher.from.should == 1
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
        performance_of { @cacher.generate_from( :florian => [1], :flavia => [2] ) }.should < 0.0001
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
  context 'from set' do
    describe 'negative from' do
      before(:each) do
        @cacher = Cacher::Partial::Substring.new :from => -2
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
    context "large from" do
      before(:each) do
        @cacher = Cacher::Partial::Substring.new :from => 10
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
    context 'default to' do
      before(:each) do
        @cacher = Cacher::Partial::Substring.new :from => 4
      end
      describe 'to' do
        it 'should return the right value' do
          @cacher.to.should == -1
        end
      end
      describe 'from' do
        it 'should return the right value' do
          @cacher.from.should == 4
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
          performance_of { @cacher.generate_from(@index) }.should < 0.008
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
          performance_of { @cacher.generate_from(@index) }.should < 0.0045
        end
      end
    end
    context 'to set' do
      before(:each) do
        @cacher = Cacher::Partial::Substring.new :from => 4, :to => -2
      end
      describe 'to' do
        it 'should return the right value' do
          @cacher.to.should == -2
        end
      end
      describe 'from' do
        it 'should return the right value' do
          @cacher.from.should == 4
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
    context 'to set' do
      before(:each) do
        @cacher = Cacher::Partial::Substring.new :from => 4, :to => 0
      end
      describe 'to' do
        it 'should return the right value' do
          @cacher.to.should == 0
        end
      end
      describe 'from' do
        it 'should return the right value' do
          @cacher.from.should == 4
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
    end
  end
  
end