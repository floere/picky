require 'spec_helper'

describe Picky::Convenience do

  before(:each) do
    @convenience = {
      :allocations => [[nil, nil, nil, nil, [1,2,3,4,5,6,7,8], [1,2,3,4,5,6,7,8]],
                       [nil, nil, nil, nil, [9,10,11,12,13,14,15,16], [9,10,11,12,13,14,15,16]],
                       [nil, nil, nil, nil, [17,18,19,20,21,22,23], [17,18,19,20,21,22,23]]],
      :offset => 123,
      :total => 12345,
      :duration => 0.12345
    }.extend Picky::Convenience
  end
  
  describe "entries" do
    context "default" do
      context "without block" do
        it "returns 20 values" do
           @convenience.entries.should == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
        end
      end
      context "with block" do
        it "yields 20 times, each time a different element" do
          amount = {}
          @convenience.entries do |entry|
            amount[entry] = true
          end
          amount.size.should == 20
        end
        it "replaces all entries" do
          @convenience.entries do |entry|
            entry + 1
          end
          @convenience.entries.should == (2..21).to_a
        end
      end
    end
    context "with value" do
      context "without block" do
        it "returns 0 entries" do
          @convenience.entries(0).should == []
        end
        it "returns 1 entry" do
          @convenience.entries(1).should == [1]
        end
        it "handles more wished entries than it has" do
          @convenience.entries(30).should == (1..23).to_a
        end
      end
      context "with block" do
        it "yields never" do
          @convenience.entries(0) do |entry|
            entry.should == :gnorf
          end
        end
        it "yields once" do
          @convenience.entries(1) do |entry|
            entry.should == 1
          end
        end
        it "yields the amount of entries it has even if more are wished" do
          amount = {}
          @convenience.entries(30) do |entry|
            amount[entry] = true
          end
          amount.size.should == 23
        end
        it "replaces all entries" do
          @convenience.entries(30) do |entry|
            entry + 1
          end
          @convenience.entries(30).should == (2..24).to_a
        end
      end
    end
  end
  
  describe "populate_with" do
    before(:each) do
      @results = {
          :allocations => [[nil, nil, nil, nil, [1,2,3,4,5,6,7,8]],
                           [nil, nil, nil, nil, [9,10,11,12,13,14,15,16]],
                           [nil, nil, nil, nil, [17,18,19,20,21,22,23]]
                          ],
           :offset => 123,
           :duration => 0.123,
           :count => 1234
         }.extend Picky::Convenience
      
      class ARClass
        attr_reader :id
        def initialize id
          @id = id
        end
        def self.find ids, options = {}
          ids.map { |id| new(id) }
        end
        def == other
          self.id == other.id
        end
      end
    end
    it "should populate correctly even without a block" do
      @results.populate_with ARClass
      @results.entries.should == (1..20).map { |id| ARClass.new(id) }
    end
    it "should populate correctly with a render block" do
      @results.populate_with(ARClass) { |ar_instance| ar_instance.id.to_s }
      @results.entries.should == (1..20).map { |id| id.to_s } # "rendering" using to_s
    end
  end
  
  describe 'replace_ids_with' do
    before(:each) do
      @results = {
          :allocations => [[nil, nil, nil, nil, [1,2,3,4,5,6,7,8]],
                           [nil, nil, nil, nil, [9,10,11,12,13,14,15,16]],
                           [nil, nil, nil, nil, [17,18,19,20,21,22,23]]
                          ],
           :offset => 123,
           :duration => 0.123,
           :count => 1234
         }.extend Picky::Convenience
    end
    it 'should populate with the entries' do
      new_ids = (11..31).to_a # +10
      @results.replace_ids_with new_ids
      @results.entries.should == (11..30).to_a
    end
  end

  describe 'clear_ids' do
    it 'should clear all ids' do
      @convenience.clear_ids

      @convenience.ids.should == []
    end
  end

  describe 'ids' do
    it 'should return the top default ids' do
      @convenience.ids.should == (1..21).to_a
    end
    it 'should return the top limit entries' do
      @convenience.ids(7).should == (1..8).to_a
    end
  end

  describe 'allocations_size' do
    it 'should just add up the allocations of both types' do
      @convenience.allocations_size.should == 3
    end
  end

  # describe 'render?' do
  #   context 'no ids' do
  #     before(:each) do
  #       @convenience.stub! :empty? => true
  #     end
  #     it 'should not render' do
  #       @convenience.render?.should == false
  #     end
  #   end
  #   context 'less results than the treshold' do
  #     before(:each) do
  #       @convenience.stub! :empty? => false
  #       @convenience.stub! :total => 7
  #     end
  #     it 'should render' do
  #       @convenience.render?.should == true
  #     end
  #   end
  #   context 'too many, but just in one allocation' do
  #     before(:each) do
  #       @convenience.stub! :empty? => false
  #       @convenience.stub! :total => 100
  #       @convenience.stub! :allocations_size => 1
  #     end
  #     it 'should render' do
  #       @convenience.render?.should == true
  #     end
  #   end
  #   context 'too many' do
  #     before(:each) do
  #       @convenience.stub! :empty? => false
  #       @convenience.stub! :total => 100
  #       @convenience.stub! :allocations_size => 2
  #     end
  #     it 'should not render' do
  #       @convenience.render?.should == false
  #     end
  #   end
  # end

  describe 'empty?' do
    context 'allocations empty' do
      before(:each) do
        @convenience.stub! :allocations => stub(:allocations, :empty? => true)
      end
      it 'should be true' do
        @convenience.empty?.should == true
      end
    end
    context 'allocations not empty' do
      before(:each) do
        @convenience.stub! :allocations => stub(:allocations, :empty? => false)
      end
      it 'should be false' do
        @convenience.empty?.should == false
      end
    end
  end

end