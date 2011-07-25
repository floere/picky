# coding: utf-8
require 'spec_helper'

describe Picky::Query::Token do
  
  describe '==' do
    it 'is equal if the originals are equal' do
      described_class.processed('similar~').should == described_class.processed('similar~')
    end
    it 'is not equal if the originals are not equal' do
      described_class.processed('similar~').should_not == described_class.processed('similar')
    end
  end
  
  describe 'next_similar_token' do
    before(:each) do
      @bundle   = stub :bundle, :similar => [:array, :of, :similar]
      @category = stub :category, :bundle_for => @bundle
      
      @token = described_class.processed 'similar~'
    end
    it 'returns the right next tokens' do
      next_token = @token.next_similar_token @category
      next_token.text.should == :array
      next_token = next_token.next_similar_token @category
      next_token.text.should == :of
      next_token = next_token.next_similar_token @category
      next_token.text.should == :similar
      next_token = next_token.next_similar_token @category
      next_token.should == nil
    end
  end
  
  describe 'next_similar' do
    before(:each) do
      @bundle = stub :bundle
    end
    describe 'original' do
      context 'with stub' do
        before(:each) do
          @bundle.stub! :similar => [:array, :of, :similar]

          @token = described_class.processed 'similar~'
        end
        it 'should have a certain original text' do
          @token.next_similar @bundle
          
          @token.original.should == :array
        end
      end
    end
    context 'similar' do
      context 'with stub' do
        before(:each) do
          @bundle.stub! :similar => [:array, :of, :similar]

          @token = described_class.processed 'similar~'
        end
        it 'generates all similar' do
          @token.next_similar(@bundle).should == :array
          @token.next_similar(@bundle).should == :of
          @token.next_similar(@bundle).should == :similar
          @token.next_similar(@bundle).should == nil
        end
        it 'should have a certain text' do
          @token.next_similar @bundle
          @token.next_similar @bundle
          @token.next_similar @bundle
          @token.next_similar @bundle
          
          @token.text.should == :similar
        end
      end
    end
    context 'non-similar' do
      context 'with stub' do
        before(:each) do
          @bundle.stub! :similar => [:array, :of, :similar]

          @token = described_class.processed 'nonsimilar'
        end
        it 'generates all similar' do
          @token.next_similar(@bundle).should == nil
        end
        it 'should have a certain text' do
          @token.next_similar @bundle
          
          @token.text.should == :nonsimilar
        end
      end
    end
  end
  
  describe "generate_similarity_for" do
    before(:each) do
      @bundle = stub :bundle
      
      @token = described_class.processed 'flarb~'
    end
    context "with similar" do
      before(:each) do
        @bundle.stub! :similar => [:array, :of, :similar]
      end
      it "returns an array of the right size" do
        @token.generate_similarity_for(@bundle).size.should == 3
      end
    end
    context "without similar" do
      before(:each) do
        @bundle.stub! :similar => []
      end
      it "returns an array of the right size" do
        @token.generate_similarity_for(@bundle).size.should == 0
      end
    end
  end
  
  # describe 'to_solr' do
  #   def self.it_should_solr text, expected_result
  #     it "should solrify into #{expected_result} from #{text}" do
  #       described_class.processed(text).to_solr.should == expected_result
  #     end
  #   end
  #   it_should_solr 's',            's'
  #   it_should_solr 'se',           'se'
  #   it_should_solr 'sea',          'sea'
  #   it_should_solr 'sear',         'sear~0.74'
  #   it_should_solr 'searc',        'searc~0.78'
  #   it_should_solr 'search',       'search~0.81'
  #   it_should_solr 'searche',      'searche~0.83'
  #   it_should_solr 'searchen',     'searchen~0.85'
  #   it_should_solr 'searcheng',    'searcheng~0.87'
  #   it_should_solr 'searchengi',   'searchengi~0.89'
  #   it_should_solr 'searchengin',  'searchengin~0.9'
  #   it_should_solr 'searchengine', 'searchengine~0.9'
  # 
  #   it_should_solr 'spec:tex',     'specific:tex'
  #   it_should_solr 'with:text',    'text~0.74'
  #   it_should_solr 'name:',        'name~0.74'
  #   it_should_solr '',             ''
  #   it_should_solr 'sp:tex',       'specific:tex'
  #   it_should_solr 'sp:tex~',      'specific:tex'
  #   it_should_solr 'sp:tex"',      'specific:tex'
  # end

  describe 'qualify' do
    def self.it_should_qualify text, expected_result
      it "should extract the qualifier #{expected_result} from #{text}" do
        described_class.new(text).qualify.should == expected_result
      end
    end
    it_should_qualify 'spec:qualifier',    [['spec'],      'qualifier']
    it_should_qualify 'with:qualifier',    [['with'],      'qualifier']
    it_should_qualify 'without qualifier', [nil,           'without qualifier']
    it_should_qualify 'name:',             [nil,           'name']
    it_should_qualify ':broken qualifier', [[],            'broken qualifier'] # Unsure about that. Probably should recognize it as text.
    it_should_qualify '',                  [nil,           '']
    it_should_qualify 'sp:text',           [['sp'],        'text']
    it_should_qualify '""',                [nil,           '""']
    it_should_qualify 'name:',             [nil,           'name']
    it_should_qualify 'name:hanke',        [['name'],      'hanke']
    it_should_qualify 'g:gaga',            [['g'],         'gaga']
    it_should_qualify ':nothing',          [[],            'nothing']
    it_should_qualify 'hello',             [nil,           'hello']
    it_should_qualify 'a:b:c',             [['a'],         'b:c']
    it_should_qualify 'a,b:c',             [['a','b'],     'c']
    it_should_qualify 'a,b,c:d',           [['a','b','c'], 'd']
    it_should_qualify ':',                 [nil,           '']
    it_should_qualify 'vorname:qualifier', [['vorname'],   'qualifier']
    it_should_qualify 'with:qualifier',    [['with'],      'qualifier']
    it_should_qualify 'without qualifier', [nil,           'without qualifier']
    it_should_qualify 'name:',             [nil,           'name']
    it_should_qualify ':broken qualifier', [[],            'broken qualifier']
    it_should_qualify '',                  [nil,           '']
    it_should_qualify 'fn:text',           [['fn'],        'text']
  end

  describe 'processed' do
    it 'should return a new token' do
      described_class.processed('some text').should be_kind_of(described_class)
    end
    it 'generates a token' do
      described_class.processed('some text').class.should == described_class
    end
  end
  
  describe 'process' do
    let(:token) { described_class.new 'any_text' }
    it 'returns itself' do
      token.process.should == token
    end
    it 'should have an order' do
      token.should_receive(:qualify).once.ordered
      token.should_receive(:extract_original).once.ordered
      token.should_receive(:downcase).once.ordered
      token.should_receive(:partialize).once.ordered
      token.should_receive(:similarize).once.ordered
      token.should_receive(:remove_illegals).once.ordered
      token.should_receive(:symbolize).once.ordered

      token.process
    end
  end

  describe 'partial?' do
    context 'similar, partial' do
      before(:each) do
        @token = described_class.processed 'similar~'
        @token.partial = true
      end
      it 'should be false' do
        @token.partial?.should == false
      end
    end
    context 'similar, not partial' do
      before(:each) do
        @token = described_class.processed 'similar~'
      end
      it 'should be false' do
        @token.partial?.should == false
      end
    end
    context 'not similar, partial' do
      before(:each) do
        @token = described_class.processed 'not similar'
        @token.partial = true
      end
      it 'should be true' do
        @token.partial?.should == true
      end
    end
    context 'not similar, not partial' do
      before(:each) do
        @token = described_class.processed 'not similar'
      end
      it 'should be nil' do
        @token.partial?.should == nil
      end
    end
  end

  describe 'similar' do
    it 'should not change the original with the text' do
      token = described_class.processed "bla~"
      token.text.should_not == token.original
    end
    def self.it_should_have_similarity text, expected_similarity_value
      it "should have #{ "no" unless expected_similarity_value } similarity for '#{text}'" do
        described_class.processed(text).similar?.should == expected_similarity_value
      end
    end
    it_should_have_similarity 'name:',      nil
    it_should_have_similarity 'name:hanke', nil
    it_should_have_similarity 'g:gaga',     nil
    it_should_have_similarity ':nothing',   nil
    it_should_have_similarity 'hello',      nil
    it_should_have_similarity 'a:b:c',      nil

    it_should_have_similarity '""',         false
    it_should_have_similarity '"exact~"',   false # The tilde will just be removed

    it_should_have_similarity '~',          true
    it_should_have_similarity '"hello"~',   true # overrides the ""
    it_should_have_similarity 'philippe~',  true
  end

  describe 'special cases' do
    it 'should be blank on ""' do
      token = described_class.processed '""'

      token.should be_blank
    end
  end

  describe "original" do
    it "should keep the original text even when processed" do
      token = described_class.processed "I'm the original token text."

      token.original.should == "I'm the original token text."
    end
  end

  describe "blank?" do
    it "should be blank if the token text itself is blank" do
      token = described_class.processed ''

      token.blank?.should be_true
    end
    it "should be non-blank if the token text itself is non-blank" do
      token = described_class.processed 'not empty'

      token.blank?.should be_false
    end
  end

  describe "to_s" do
    describe "with qualifier" do
      it "should display qualifier and text combined with a ':'" do
        token = described_class.processed('sp:qualifier')

        token.to_s.should == 'Picky::Query::Token(qualifier, ["sp"])'
      end
    end
    describe "without qualifier" do
      it "should display just the text" do
        token = described_class.processed('text')

        token.to_s.should == 'Picky::Query::Token(text)'
      end
    end
  end

  describe 'qualifiers' do
    context 'with qualifier' do
      before(:each) do
        @token = described_class.processed('sp:qualifier')
      end
      it 'should return the qualifier' do
        @token.qualifiers.should == ['sp']
      end
    end
    context 'with incorrect qualifier' do
      before(:each) do
        @token = described_class.processed('specific:qualifier')
      end
      it 'should return the qualifier' do
        @token.qualifiers.should == ['specific']
      end
    end
    context 'with multiple qualifiers' do
      before(:each) do
        @token = described_class.processed('sp,spec:qualifier')
      end
      it 'should return the qualifier' do
        @token.qualifiers.should == ['sp', 'spec']
      end
    end
    context 'without qualifier' do
      before(:each) do
        @token = described_class.processed('noqualifier')
      end
      it 'should return nil' do
        @token.qualifiers.should == nil
      end
    end
  end

  describe 'partial=' do
    context 'partial nil' do
      before(:each) do
        @token = described_class.new 'text'
      end
      it 'should set partial' do
        @token.partial = true

        @token.instance_variable_get(:@partial).should be_true
      end
      it 'should set partial' do
        @token.partial = false

        @token.instance_variable_get(:@partial).should be_false
      end
    end
    context 'partial not nil' do
      before(:each) do
        @token = described_class.processed 'text*'
      end
      it 'should not set partial' do
        @token.instance_variable_set :@partial, false
        
        @token.partial = true

        @token.instance_variable_get(:@partial).should be_false
      end
      it 'should not set partial' do
        @token.partial = false

        @token.instance_variable_get(:@partial).should be_true
      end
    end
  end

  describe 'partialize!' do
    it 'should not partialize a token if the text ends with "' do
      token = described_class.processed 'text"'

      token.instance_variable_get(:@partial).should be_false
    end
    it 'should partialize a token if the text ends with *' do
      token = described_class.processed 'text*'

      token.instance_variable_get(:@partial).should be_true
    end
    it 'should not partialize a token if the text ends with ~' do
      token = described_class.processed 'text~'

      token.instance_variable_get(:@partial).should be_nil
    end
  end

  describe "processed" do
    it 'should remove *' do
      token = described_class.processed 'text*'

      token.text.should == :text
    end
    it 'should remove ~' do
      token = described_class.processed 'text~'

      token.text.should == :text
    end
    it 'should remove "' do
      token = described_class.processed 'text"'

      token.text.should == :text
    end
    it "should pass on a processed text" do
      described_class.processed('text').text.should == :text
    end
  end

end