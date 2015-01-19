# encoding: utf-8
#
require 'spec_helper'
require 'ostruct'

describe "OR token" do
  
  # We use the same search throughout.
  #
  let(:try) { Picky::Search.new index }
  
  context 'simple cases' do
    let(:index) do
      index = Picky::Index.new :or do
        category :text
      end
      thing = OpenStruct.new id: 1, text: "hello ohai"
      other = OpenStruct.new id: 2, text: "hello kthxbye"

      index.add thing
      index.add other
      
      index
    end
    it { try.search("hello text:ohai|text:kthxbye").ids.should == [1, 2] }
    it { try.search("hello text:ohai|kthxbye").ids.should == [1, 2] }
    it { try.search("hello ohai|text:kthxbye").ids.should == [1, 2] }
    it { try.search("hello ohai|kthxbye").ids.should == [1, 2] }
    it('still works') { try.search("hello text:ohai").ids.should == [1] }
  end
  
  context 'simple cases with symbol_keys' do
    let(:index) do
      index = Picky::Index.new :or do
        symbol_keys true
        category :text
      end
      thing = OpenStruct.new id: 1, text: "hello ohai"
      other = OpenStruct.new id: 2, text: "hello kthxbye"

      index.add thing
      index.add other
      
      index
    end
    let(:try) { Picky::Search.new(index) { symbol_keys } }
    it { try.search("hello text:ohai|text:kthxbye").ids.should == [1, 2] }
    it { try.search("hello text:ohai|kthxbye").ids.should == [1, 2] }
    it { try.search("hello ohai|text:kthxbye").ids.should == [1, 2] }
    it { try.search("hello ohai|kthxbye").ids.should == [1, 2] }
    it('still works') { try.search("hello text:ohai").ids.should == [1] }
  end
  
  context 'more complex cases' do
    let(:index) do
      index = Picky::Index.new :or do
        category :text1
        category :text2
      end

      thing = OpenStruct.new id: 1, text1: "hello world", text2: "ohai kthxbye"
      other = OpenStruct.new id: 2, text1: "hello something else", text2: "to be or not to be"

      index.add thing
      index.add other
      
      index
    end
    
    # Note that the order is changed.
    #
    it { try.search("hello ohai|not").ids.should == [1, 2] }
    it { try.search("hello not|ohai").ids.should == [2, 1] }
    it { try.search("hello ohai|kthxbye").ids.should == [1] }
    it { try.search("hello nonexisting|not").ids.should == [2] }
    it { try.search("hello nonexisting|alsononexisting").ids.should == [] }
    it { try.search("hello text1:world|text2:not|text2:kthxbye").ids.should == [1, 2] }
  end
  
  context 'even more complex cases' do
    let(:index) do
      index = Picky::Index.new :or do
        category :text, similarity: Picky::Similarity::DoubleMetaphone.new(3)
      end

      thing = OpenStruct.new id: 1, text: "hello ohai tester 13"
      other = OpenStruct.new id: 2, text: "hello kthxbye"

      index.add thing
      index.add other

      index
    end
    
    it { try.search("something,other:ohai").ids.should == [] }
    it { try.search("text:taster~|text:kthxbye hello").ids.should == [2, 1] }
    it { try.search("text:test*|kthxbye hello").ids.should == [2, 1] }
    it { try.search("text:11…15|kthxbye hello").ids.should == [2, 1] }
    it { try.search("hello text,other:ohai|text:kthxbye").ids.should == [1, 2] }
    it { try.search("hello something,other:ohai|kthxbye").ids.should == [2] }
    it { try.search("hello text:oh*|text:kthxbya~").ids.should == [1, 2] }
  end
  
  context 'multi-ORs' do
    let(:index) do
      index = Picky::Index.new :or do
        category :text, similarity: Picky::Similarity::DoubleMetaphone.new(3)
      end

      thing     = OpenStruct.new id: 1, text: "that thing"
      something = OpenStruct.new id: 2, text: "and something"
      other     = OpenStruct.new id: 3, text: "or other"

      index.add thing
      index.add something
      index.add other
      
      index
    end
    
    it { try.search("thing|something|other").ids.should == [1, 2, 3] }
    it { try.search("something|other").ids.should == [2, 3] }
    it { try.search("other|something").ids.should == [3, 2] }
  end

end