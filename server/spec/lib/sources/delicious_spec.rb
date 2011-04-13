require 'spec_helper'

describe Sources::Delicious do
  
  context "with file" do
    
    describe 'to_s' do
      it 'outputs correctly' do
        described_class.new(:username, :password).to_s.should == 'Sources::Delicious(username)'
      end
    end
    
    describe "check_gem" do
      before(:each) do
        @source = Sources::Delicious.allocate
      end
      context "doesn't find www/delicious" do
        before(:each) do
          @source.should_receive(:require).any_number_of_times.and_raise LoadError
        end
        it "warns & exits" do
          @source.should_receive(:warn).once.with "www-delicious gem missing!\nTo use the delicious source, you need to:\n  1. Add the following line to Gemfile:\n     gem 'www-delicious'\n  2. Then, run:\n     bundle update\n"
          @source.should_receive(:exit).once.with 1
          
          @source.check_gem
        end
      end
      context "finds www/delicious" do
        before(:each) do
          @source.should_receive(:require).any_number_of_times.and_return
        end
        it "checks if the gem is there" do
          lambda { @source.check_gem }.should_not raise_error
        end
      end
    end
    
    describe "harvest" do
      before(:each) do
        @source = Sources::Delicious.new(:username, :password)

        post1       = WWW::Delicious::Post.new
        post1.uid   = "5045d67b3f251e4ae966dffe71501763"
        post1.tags  = ["barefoot", "running", "shoe"]
        post1.title = "VIBRAM - FiveFingers"
        post1.url   = URI.parse('http://www.vibramfivefingers.it/')
        
        delicious = stub :delicious, :posts_recent => [post1]
        
        WWW::Delicious.should_receive(:new).and_return delicious
      end
      it "should yield the right data" do
        category = stub :b, :from => :tags
        @source.harvest category do |id, token|
          [id, token].should == [1, "barefoot running shoe"]
        end
      end
      it "should yield the right data" do
        category = stub :b, :from => :title
        @source.harvest category do |id, token|
          [id, token].should == [1, "VIBRAM - FiveFingers"]
        end
      end
      it "should yield the right data" do
        category = stub :b, :from => :url
        @source.harvest category do |id, token|
          [id, token].should == [1, "http://www.vibramfivefingers.it/"]
        end
      end
    end
    describe "get_data" do
      before(:each) do
        @source = Sources::Delicious.new(:username, :password)
        
        post1       = WWW::Delicious::Post.new
        post1.uid   = "5045d67b3f251e4ae966dffe71501763"
        post1.tags  = ["barefoot", "running", "shoe"]
        post1.title = "VIBRAM - FiveFingers"
        post1.url   = URI.parse('http://www.vibramfivefingers.it/')
        
        delicious = stub :delicious, :posts_recent => [post1]
        
        WWW::Delicious.should_receive(:new).and_return delicious
      end
      it "should yield each line" do
        @source.get_data do |uid, data|
          uid.should  == 1
          data.should == { :title => "VIBRAM - FiveFingers", :tags => "barefoot running shoe", :url => "http://www.vibramfivefingers.it/" }
        end
      end
    end
  end
  
end