# encoding: utf-8
#
require 'spec_helper'

describe "automatic splitting" do
  
  let(:index) do
    index = Picky::Index.new :automatic_text_splitting do
      indexing removes_characters: /[^a-z\s]/i,
               stopwords: /\b(in|a)\b/
      category :text
    end

    require 'ostruct'
    index.add OpenStruct.new(id: 1, text: 'It does rain in Spain. Purple is a new color. Bow to the king.')
    index.add OpenStruct.new(id: 2, text: 'Rainbow rainbow.')
    index.add OpenStruct.new(id: 3, text: 'Bow and arrow in Papua New Guinea.')
    index.add OpenStruct.new(id: 4, text: 'The color purple.')
    index.add OpenStruct.new(id: 5, text: 'Sun and rain.')
    index.add OpenStruct.new(id: 6, text: 'The king is in Spain.')
    
    index
  end

  context 'splitting the text automatically' do
    let(:automatic_splitter) { Picky::Splitters::Automatic.new index[:text] }
    
    # It splits the text correctly.
    #
    it do
      automatic_splitter.segment('purplerainbow').should == [
        ['purple', 'rain', 'bow'],
        2.078999999999999
      ]
    end
  end
  
  context 'splitting the text automatically' do
    let(:automatic_splitter) { Picky::Splitters::Automatic.new index[:text] }
    
    # It splits the text correctly.
    #
    it { automatic_splitter.split('purplerainbow').should == ['purple', 'rain', 'bow'] }
    it { automatic_splitter.split('purplerain').should == ['purple', 'rain'] }
    it { automatic_splitter.split('purple').should == ['purple'] }
    
    # When it can't, it splits it using the partial index (correctly).
    #
    it { automatic_splitter.split('purplerainbo').should == ['purple', 'rain'] }
    it { automatic_splitter.split('purplerainb').should  == ['purple', 'rain'] }
    #
    it { automatic_splitter.split('purplerai').should == ['purple'] }
    it { automatic_splitter.split('purplera').should  == ['purple'] }
    it { automatic_splitter.split('purpler').should   == ['purple'] }
    #
    it { automatic_splitter.split('purpl').should == [] }
    it { automatic_splitter.split('purp').should  == [] }
    it { automatic_splitter.split('pur').should   == [] }
    it { automatic_splitter.split('pu').should    == [] }
    it { automatic_splitter.split('p').should     == [] }
  end
  
  context 'splitting text automatically (with partial)' do
    let(:automatic_splitter) { Picky::Splitters::Automatic.new index[:text], partial: true }
    
    # It splits the text correctly.
    #
    it { automatic_splitter.split('purplerainbow').should == ['purple', 'rain', 'bow'] }
    it { automatic_splitter.split('purplerain').should == ['purple', 'rain'] }
    it { automatic_splitter.split('purple').should == ['purple'] }
    
    # Creates the right queries (see below).
    #
    it { automatic_splitter.split('colorpurple').should == ['color', 'purple'] }
    it { automatic_splitter.split('bownew').should == ['bow', 'new'] }
    it { automatic_splitter.split('spainisking').should == ['spain', 'is', 'king'] }
    
    # When it can't, it splits it using the partial index (correctly).
    #
    it { automatic_splitter.split('purplerainbo').should == ['purple', 'rain', 'bo'] }
    it { automatic_splitter.split('purplerainb').should == ['purple', 'rain', 'b'] }
    #
    it { automatic_splitter.split('purplerai').should == ['purple', 'rai'] }
    it { automatic_splitter.split('purplera').should == ['purple', 'ra'] }
    it { automatic_splitter.split('purpler').should == ['purple'] } # No 'r' in partial index.
    #
    it { automatic_splitter.split('purpl').should == ['purpl'] }
    it { automatic_splitter.split('purp').should == ['purp'] }
    it { automatic_splitter.split('pur').should == [] } # No 'pur' in partial index etc.
    it { automatic_splitter.split('pu').should == [] }
    it { automatic_splitter.split('p').should == [] }
    
    let(:try) do
      splitter = automatic_splitter
      Picky::Search.new index do
        searching splits_text_on: splitter
      end
    end
    
    # Should find the one with all parts.
    #
    it { try.search('purplerainbow').ids.should == [1] }
    it { try.search('sunandrain').ids.should == [5] }
    
    # Common parts are found in multiple examples.
    #
    it { try.search('colorpurple').ids.should == [4,1] }
    it { try.search('bownew').ids.should      == [3,1] }
    it { try.search('spainisking').ids.should == [6,1] }
  end
  
  it 'is fast enough' do
    automatic_splitter = Picky::Splitters::Automatic.new index[:text]
    
    performance_of do
      automatic_splitter.split('purplerainbow')
    end.should < 0.0002
  end

end