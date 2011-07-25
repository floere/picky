require 'spec_helper'

describe Picky::Sources::Mongo do
  
  describe 'key_format' do
    context 'default' do
      let(:source) { described_class.new(:a, :b, :url => 'someurl', :db => 'somedb') }
      it 'is correct' do
        source.key_format.should == :to_sym
      end
    end

    context 'non-default' do
      let(:source) { described_class.new(:a, :b, :url => 'bla', :db => 'somedb', :key_format => 'some_key_method') }
      it 'is correct' do
        source.key_format.should == :some_key_method
      end
    end
  end
  
  describe 'to_s' do
     let(:source) { described_class.new(:a, :b, :url => 'someurl', :db => 'somedb') }
     it 'is correct' do
       source.to_s.should == 'Picky::Sources::Mongo'
     end
   end
   
   context "without database" do
     it "should fail correctly" do
       lambda { @source = described_class.new(:a, :b, :url => 'someurl') }.should raise_error(described_class::NoDBGiven)
     end
   end

   context "with database" do
     before(:each) do
       @source = described_class.new :a, :b, :url => 'someurl', :db => 'somedb'
       RestClient::Request.should_receive(:execute).any_number_of_times.and_return %{{"rows":[{"_id":"7f","a":"a data","b":"b data","c":"c data"}]}}
     end

     describe "harvest" do
       it "yields the right data" do
         category = stub :b, :from => :b, :index_name => :some_index_name
         @source.harvest category do |id, token|
           id.should    eql('7f') 
           token.should eql('b data')
         end.should have(1).item
       end
     end
   end
end
