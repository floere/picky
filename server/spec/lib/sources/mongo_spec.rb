require 'spec_helper'

describe Sources::Mongo do
  
  describe 'key_format' do
    context 'default' do
      let(:source) { Sources::Mongo.new(:a, :b, :url => 'someurl', :db => 'somedb') }
      it 'is correct' do
        source.key_format.should == :to_sym
      end
    end

    context 'non-default' do
      let(:source) { Sources::Mongo.new(:a, :b, :url => 'bla', :db => 'somedb', :key_format => 'some_key_method') }
      it 'is correct' do
        source.key_format.should == :some_key_method
      end
    end
  end
  
  describe 'to_s' do
     let(:source) { Sources::Mongo.new(:a, :b, :url => 'someurl', :db => 'somedb') }
     it 'is correct' do
			 puts ">>>>#{source.class}"
       source.to_s.should == 'Sources::Mongo'
     end
   end
   
   describe 'special keys' do
     context 'uuid keys' do
       context "with database" do
         before(:each) do
           @source = Sources::Mongo.new(:a, :b, :c, :url => 'http://localhost:5984/picky', :db => 'somedb')
           RestClient::Request.should_receive(:execute).any_number_of_times.and_return %{"offset" : 0, "rows":[{"doc":{"_id": { "$oid" : "550e8400-e29b-41d4-a716-446655440000"},"a":"a data","b":"b data","c":"c data"}}]}
         end     
  
         describe "harvest" do
           it "yields the right data" do
             category = stub :b, :from => :b
             @source.harvest category do |id, token|
               id.should    eql('550e8400-e29b-41d4-a716-446655440000') 
               token.should eql('b data')
             end.should have(1).item
           end
         end
  
         describe "get_data" do
           it "yields each line" do
             @source.get_data do |data|
               data.should == { "_id" => "550e8400-e29b-41d4-a716-446655440000", "a" => "a data", "b" => "b data", "c" => "c data" }
             end.should have(1).item
           end
         end
       end
     end
     context 'integer keys' do
       context "with database" do
         before(:each) do
           @source = Sources::Mongo.new(:a, :b, :c, :url => 'http://localhost:5984/picky', :db => 'somedb')
           RestClient::Request.should_receive(:execute).any_number_of_times.and_return %{"offset" : 0, "rows":[{"doc":{"_id": { "$oid" : "123"},"a":"a data","b":"b data","c":"c data"}}]}
         end
  
         describe "harvest" do
           it "yields the right data" do
             category = stub :b, :from => :b
						 category = stub :b, :index_name => :b
             @source.harvest category do |id, token|
               id.should    eql('123') 
               token.should eql('b data')
             end.should have(1).item
           end
         end
       end
     end
   end
  #  
  #  context 'default keys' do
  #    context "without database" do
  #      it "should fail correctly" do
  #        lambda { @source = Sources::Mongo.new(:a, :b, :c) }.should raise_error(Sources::NoMongoDBGiven)
  #      end
  #    end
  # 
  #    context "with database" do
  #      before(:each) do
  #        @source = Sources::Mongo.new :a, :b, :c, url: 'http://localhost:5984/picky'
  #        RestClient::Request.should_receive(:execute).any_number_of_times.and_return %{{"rows":[{"doc":{"_id":"7f","a":"a data","b":"b data","c":"c data"}}]}}
  #      end
  # 
  #      describe "harvest" do
  #        it "yields the right data" do
  #          category = stub :b, :from => :b
  #          @source.harvest category do |id, token|
  #            id.should    eql('7f') 
  #            token.should eql('b data')
  #          end.should have(1).item
  #        end
  #      end
  # 
  #      describe "get_data" do
  #        it "yields each line" do
  #          @source.get_data do |data|
  #            data.should == { "_id" => "7f", "a" => "a data", "b" => "b data", "c" => "c data" }
  #          end.should have(1).item
  #        end
  #      end
  #    end
  #  end
end
