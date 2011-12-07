# coding: utf-8
require 'spec_helper'

describe Picky::Query::Token do

  describe '==' do
    it 'is equal if the originals are equal' do
      described_class.processed('similar~', 'Similar~').should == described_class.processed('similar~', 'Similar~')
    end
    it 'is not equal if the originals are not equal' do
      described_class.processed('similar~', 'Similar~').should_not == described_class.processed('similar', 'Similar')
    end
  end

  describe 'similar_tokens_for' do
    let(:token) { described_class.processed 'similar~', 'Similar~' }
    context 'with similar' do
      before(:each) do
        @bundle   = stub :bundle, :similar => ['array', 'of', 'similar']
        @category = stub :category, :bundle_for => @bundle
      end
      it 'returns a list of tokens' do
        token.similar_tokens_for(@category).each do |token|
          token.should be_kind_of(described_class)
        end
      end
      it 'returns all non-similar tokens' do
        token.similar_tokens_for(@category).each do |token|
          token.should_not be_similar
        end
      end
      it 'returns a list of tokens with the right text' do
        token.similar_tokens_for(@category).map(&:text).should == ['array', 'of', 'similar']
      end
      it 'returns a list of tokens with the right original' do
        token.similar_tokens_for(@category).map(&:original).should == ['array', 'of', 'similar']
      end
      it 'returns a list of tokens with the right categorization' do
        token.similar_tokens_for(@category).map(&:user_defined_categories).should == [[@category], [@category], [@category]]
      end
    end
    context 'without similar' do
      before(:each) do
        @bundle   = stub :bundle, :similar => []
        @category = stub :category, :bundle_for => @bundle
      end
      it 'returns an empty list' do
        token.similar_tokens_for(@category).should == []
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
      described_class.processed('some text', 'SOME TEXT').should be_kind_of(described_class)
    end
    it 'generates a token' do
      described_class.processed('some text', 'SOME TEXT').class.should == described_class
    end
  end

  describe 'process' do
    let(:token) { described_class.new 'any_text' }
    it 'returns itself' do
      token.process.should == token
    end
    it 'should have an order' do
      token.should_receive(:qualify).once.ordered
      token.should_receive(:partialize).once.ordered
      token.should_receive(:similarize).once.ordered
      token.should_receive(:remove_illegals).once.ordered

      token.process
    end
  end

  describe 'symbolize!' do
    before(:each) do
      @token = described_class.processed 'string', 'String'
    end
    it 'is not symbolized' do
      @token.text.should == 'string'
    end
    it 'can be symbolized' do
      @token.symbolize!

      @token.text.should == :string
    end
  end

  describe 'partial?' do
    context 'similar, partial' do
      before(:each) do
        @token = described_class.processed 'similar~', 'Similar~'
        @token.partial = true
      end
      it 'should be false' do
        @token.partial?.should == false
      end
    end
    context 'similar, not partial' do
      before(:each) do
        @token = described_class.processed 'similar~', 'Similar~'
      end
      it 'should be false' do
        @token.partial?.should == false
      end
    end
    context 'not similar, partial' do
      before(:each) do
        @token = described_class.processed 'not similar', 'NOT SIMILAR'
        @token.partial = true
      end
      it 'should be true' do
        @token.partial?.should == true
      end
    end
    context 'not similar, not partial' do
      before(:each) do
        @token = described_class.processed 'not similar', 'NOT SIMILAR'
      end
      it 'should be nil' do
        @token.partial?.should == nil
      end
    end
  end

  describe 'similar' do
    it 'should not change the original with the text' do
      token = described_class.processed "bla~", 'BLA~'
      token.text.should_not == token.original
    end
    def self.it_should_have_similarity text, expected_similarity_value
      it "should have #{ "no" unless expected_similarity_value } similarity for '#{text}'" do
        described_class.processed(text, text.upcase).similar?.should == expected_similarity_value
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
      token = described_class.processed '""', '""'

      token.should be_blank
    end
  end

  describe "original" do
    it "should keep the original text even when processed" do
      token = described_class.processed "I'm the processed text.", "I'm the original text."

      token.original.should == "I'm the original text."
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
    it 'lets the last one win' do
      token = described_class.processed 'text"*'

      token.partial?.should == true
    end
    it 'lets the last one win' do
      token = described_class.processed 'text*"'

      token.partial?.should == false
    end
  end

  describe "processed" do
    it 'should remove *' do
      token = described_class.processed 'text*'

      token.text.should == 'text'
    end
    it 'should remove ~' do
      token = described_class.processed 'text~'

      token.text.should == 'text'
    end
    it 'should remove "' do
      token = described_class.processed 'text"'

      token.text.should == 'text'
    end
    it "should pass on a processed text" do
      described_class.processed('text').text.should == 'text'
    end
  end

end