require 'spec_helper'

describe Sources::Delicious do
  
  context "with file" do

    describe "harvest" do
      before(:each) do
        @source = Sources::Delicious.new(:username, :password)

        post1       = WWW::Delicious::Post.new
        post1.uid   = "5045d67b3f251e4ae966dffe71501763"
        post1.tags  = ["barefoot", "running", "shoe"]
        post1.title = "VIBRAM - FiveFingers"
        post1.url   = URI.parse('http://www.vibramfivefingers.it/')
        
        # post2       = WWW::Delicious::Post.new
        # post2.uid   = "d0b16f4b7e998a3386052bc95ad0d695"
        # post2.tags  = ["floating", "title", "scrolling", "css", "javascript", "ui"]
        # post2.title = "Floating Title when Scrolling"
        # post2.url   = URI.parse('http://mesh.scribblelive.com/Event/Value_Judgements_in_Interface_Design5')
        
        delicious = stub :delicious, :posts_recent => [post1]
        
        WWW::Delicious.should_receive(:new).and_return delicious
      end
      it "should yield the right data" do
        field = stub :b, :name => :tags
        @source.harvest :anything, field do |id, token|
          [id, token].should == [1, "barefoot running shoe"]
        end
      end
      it "should yield the right data" do
        field = stub :b, :name => :title
        @source.harvest :anything, field do |id, token|
          [id, token].should == [1, "VIBRAM - FiveFingers"]
        end
      end
      it "should yield the right data" do
        field = stub :b, :name => :url
        @source.harvest :anything, field do |id, token|
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
        
        # post2       = WWW::Delicious::Post.new
        # post2.uid   = "d0b16f4b7e998a3386052bc95ad0d695"
        # post2.tags  = ["floating", "title", "scrolling", "css", "javascript", "ui"]
        # post2.title = "Floating Title when Scrolling"
        # post2.url   = URI.parse('http://mesh.scribblelive.com/Event/Value_Judgements_in_Interface_Design5')
        
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