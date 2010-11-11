require 'spec_helper'

describe Indexed::Categories do
  
  context 'with option ignore_unassigned_tokens' do
    context 'ignore_unassigned_tokens true' do
      before(:each) do
        @categories = Indexed::Categories.new ignore_unassigned_tokens: true
      end
      it 'should return the right value' do
        @categories.ignore_unassigned_tokens.should == true
      end
    end
    context 'ignore_unassigned_tokens false' do
      before(:each) do
        @categories = Indexed::Categories.new ignore_unassigned_tokens: false
      end
      it 'should return the right value' do
        @categories.ignore_unassigned_tokens.should == false
      end
    end
  end
  
  context "with real categories" do
    before(:each) do
      @type1 = stub :type1, :name => :some_type
      
      @categories = Indexed::Categories.new
      @categories << Indexed::Category.new(:category1, @type1)
      @categories << Indexed::Category.new(:category2, @type1)
      @categories << Indexed::Category.new(:category3, @type1)
    end
    describe "similar_possible_for" do
      before(:each) do
        @token = Query::Token.processed 'similar~'
      end
      it "returns possible categories" do
        @categories.similar_possible_for(@token).should == []
      end
    end
  end
  
  context 'without options' do
    before(:each) do
      @type1 = stub :type1, :name => :some_type
      
      @category1 = Indexed::Category.new :category1, @type1
      @category2 = Indexed::Category.new :category2, @type1
      @category3 = Indexed::Category.new :category3, @type1
      
      @categories = Indexed::Categories.new
      @categories << @category1
      @categories << @category2
      @categories << @category3
    end
    
    describe "possible_combinations_for" do
      before(:each) do
        @token = stub :token
      end
      context "with similar token" do
        before(:each) do
          @token.stub :similar? => true
        end
        it "calls the right method" do
          @categories.should_receive(:similar_possible_for).once.with @token
          
          @categories.possible_combinations_for @token
        end
      end
      context "with non-similar token" do
        before(:each) do
          @token.stub :similar? => false
        end
        it "calls the right method" do
          @categories.should_receive(:possible_for).once.with @token
          
          @categories.possible_combinations_for @token
        end
      end
    end
    
    describe 'possible_for' do
      context 'without preselected categories' do
        context 'user defined exists' do
          before(:each) do
            @token = stub :token, :user_defined_category_name => :category2
          end
          context 'combination exists' do
            before(:each) do
              @combination = stub :combination
              @category2.stub! :combination_for => @combination
            end
            it 'should return the right combinations' do
              @categories.possible_for(@token).should == [@combination]
            end
          end
          context 'combination does not exist' do
            before(:each) do
              @category2.stub! :combination_for => nil
            end
            it 'should return the right combinations' do
              @categories.possible_for(@token).should == []
            end
          end
        end
        context 'user defined does not exist' do

        end
      end
      context 'with preselected categories' do

      end
    end

    describe 'possible_categories' do
      context 'user defined exists' do
        before(:each) do
          @token = stub :token, :user_defined_category_name => :category2
        end
        it 'should return the right categories' do
          @categories.possible_categories(@token).should == [@category2]
        end
      end
      context 'user defined does not exist' do
        before(:each) do
          @token = stub :token, :user_defined_category_name => nil
        end
        it 'should return all categories' do
          @categories.possible_categories(@token).should == [@category1, @category2, @category3]
        end
      end
    end

    describe 'user_defined_categories' do
      context 'category exists' do
        before(:each) do
          @token = stub :token, :user_defined_category_name => :category2
        end
        it 'should return the right categories' do
          @categories.user_defined_categories(@token).should == [@category2]
        end
      end
      context 'category does not exist' do
        before(:each) do
          @token = stub :token, :user_defined_category_name => :gnoergel
        end
        it 'should return nil' do
          @categories.user_defined_categories(@token).should == nil
        end
      end
    end
  end
  
end