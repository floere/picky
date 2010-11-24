require 'spec_helper'
require 'csv'

describe Sources::CSV do
  
  describe 'without separator' do
    before(:each) do
      @source = Sources::CSV.new :a, :b, :c, :file => :some_file
    end
    it 'calls foreach correctly' do
      block = lambda { |*args| }
      
      ::CSV.should_receive(:foreach).once.with :some_file, {}, &block
      
      @source.get_data &block
    end
  end
  describe 'with separator' do
    before(:each) do
      @source = Sources::CSV.new :a, :b, :c, :file => :some_file, :col_sep => 'some_separator'
    end
    it 'calls foreach correctly' do
      block = lambda { |*args| }
      
      ::CSV.should_receive(:foreach).once.with :some_file, :col_sep => 'some_separator', &block
      
      @source.get_data &block
    end
  end
  
  context "without file" do
    it "should fail correctly" do
      lambda { @source = Sources::CSV.new(:a, :b, :c) }.should raise_error(Sources::NoCSVFileGiven)
    end
  end
  context "with file" do
    before(:each) do
      ::CSV.should_receive(:foreach).any_number_of_times.and_yield ['7', 'a data', 'b data', 'c data']
    end
    context 'without separator' do
      before(:each) do
        @source = Sources::CSV.new :a, :b, :c, :file => :some_file
      end
      describe "harvest" do
        it "should yield the right data" do
          field = stub :b, :name => :b
          @source.harvest :anything, field do |id, token|
            [id, token].should == [7, 'b data']
          end
        end
      end
      describe "get_data" do
        it "should yield each line" do
          @source.get_data do |data|
            data.should == ['7', 'a data', 'b data', 'c data']
          end
        end
      end
    end
  end
  
end