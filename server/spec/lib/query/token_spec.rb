# coding: utf-8
require 'spec_helper'

describe Query::Token do
  
  before(:all) do
    Query::Qualifiers.instance << Query::Qualifier.new(:specific, [:sp, :spec])
    Query::Qualifiers.instance.prepare
  end
  
  describe "generate_similarity_for" do
    before(:each) do
      @bundle = stub :bundle
      
      @token = Query::Token.processed 'flarb~'
    end
    context "with similar" do
      before(:each) do
        @bundle.stub! :similar => [:array, :of, :similar]
      end
      it "returns an enumerator" do
        @token.generate_similarity_for(@bundle).to_a.size.should == 3
      end
    end
    context "without similar" do
      before(:each) do
        @bundle.stub! :similar => nil
      end
      it "returns an enumerator with 0 entries" do
        @token.generate_similarity_for(@bundle).to_a.size.should == 0
      end
    end
  end
  
  describe 'to_solr' do
    def self.it_should_solr text, expected_result
      it "should solrify into #{expected_result} from #{text}" do
        Query::Token.processed(text).to_solr.should == expected_result
      end
    end
    it_should_solr 's',            's'
    it_should_solr 'se',           'se'
    it_should_solr 'sea',          'sea'
    it_should_solr 'sear',         'sear~0.74'
    it_should_solr 'searc',        'searc~0.78'
    it_should_solr 'search',       'search~0.81'
    it_should_solr 'searche',      'searche~0.83'
    it_should_solr 'searchen',     'searchen~0.85'
    it_should_solr 'searcheng',    'searcheng~0.87'
    it_should_solr 'searchengi',   'searchengi~0.89'
    it_should_solr 'searchengin',  'searchengin~0.9'
    it_should_solr 'searchengine', 'searchengine~0.9'

    it_should_solr 'spec:tex',     'specific:tex'
    it_should_solr 'with:text',    'text~0.74'
    it_should_solr 'name:',        'name~0.74'
    it_should_solr '',             ''
    it_should_solr 'sp:tex',       'specific:tex'
    it_should_solr 'sp:tex~',      'specific:tex'
    it_should_solr 'sp:tex"',      'specific:tex'
  end

  describe 'qualify' do
    def self.it_should_qualify text, expected_result
      it "should extract the qualifier #{expected_result} from #{text}" do
        Query::Token.new(text).qualify.should == expected_result
      end
    end
    it_should_qualify 'spec:qualifier',    :specific
    it_should_qualify 'with:qualifier',    nil
    it_should_qualify 'without qualifier', nil
    it_should_qualify 'name:',             nil
    it_should_qualify ':broken qualifier', nil
    it_should_qualify '',                  nil
    it_should_qualify 'sp:text',           :specific
  end

  describe 'processed' do
    it 'should have an order' do
      token = stub :token
      Query::Token.should_receive(:new).once.and_return token

      token.should_receive(:qualify).once.ordered
      token.should_receive(:extract_original).once.ordered
      token.should_receive(:partialize).once.ordered
      token.should_receive(:similarize).once.ordered
      token.should_receive(:remove_illegals).once.ordered

      Query::Token.processed :any_text
    end
    it 'should return a new token' do
      Query::Token.processed('some text').should be_kind_of(Query::Token)
    end
  end

  describe 'partial?' do
    context 'similar, partial' do
      before(:each) do
        @token = Query::Token.processed 'similar~'
        @token.partial = true
      end
      it 'should be false' do
        @token.partial?.should == false
      end
    end
    context 'similar, not partial' do
      before(:each) do
        @token = Query::Token.processed 'similar~'
      end
      it 'should be false' do
        @token.partial?.should == false
      end
    end
    context 'not similar, partial' do
      before(:each) do
        @token = Query::Token.processed 'not similar'
        @token.partial = true
      end
      it 'should be true' do
        @token.partial?.should == true
      end
    end
    context 'not similar, not partial' do
      before(:each) do
        @token = Query::Token.processed 'not similar'
      end
      it 'should be nil' do
        @token.partial?.should == nil
      end
    end
  end

  describe 'similar' do
    it 'should not change the original with the text' do
      token = Query::Token.processed "bla~"
      token.text.should_not == token.original
    end
    def self.it_should_have_similarity text, expected_similarity_value
      it "should have #{ "no" unless expected_similarity_value } similarity for '#{text}'" do
        Query::Token.processed(text).similar?.should == expected_similarity_value
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
      token = Query::Token.processed '""'

      token.should be_blank
    end
  end

  describe 'split' do
    def self.it_should_split text, expected_qualifier
      it "should extract #{expected_qualifier} from #{text}" do
        Query::Token.new('any').send(:split, text).should == expected_qualifier
      end
    end
    it_should_split '""',         [nil, '""']
    it_should_split 'name:',      [nil, 'name']
    it_should_split 'name:hanke', ['name', 'hanke']
    it_should_split 'g:gaga',     ['g', 'gaga']
    it_should_split ':nothing',   ['', 'nothing']
    it_should_split 'hello',      [nil, 'hello']
    it_should_split 'a:b:c',      ['a', 'b:c']
  end

  describe "original" do
    it "should keep the original text even when processed" do
      token = Query::Token.processed "I'm the original token text."

      token.original.should == "I'm the original token text."
    end
  end

  describe "blank?" do
    it "should be blank if the token text itself is blank" do
      token = Query::Token.processed ''

      token.blank?.should be_true
    end
    it "should be non-blank if the token text itself is non-blank" do
      token = Query::Token.processed 'not empty'

      token.blank?.should be_false
    end
  end

  describe "to_s" do
    describe "with qualifier" do
      it "should display qualifier and text combined with a ':'" do
        token = Query::Token.processed('sp:qualifier')

        token.to_s.should == 'specific:qualifier'
      end
    end
    describe "without qualifier" do
      it "should display just the text" do
        token = Query::Token.processed('text')

        token.to_s.should == 'text'
      end
    end
  end

  describe 'user_defined_category_name' do
    context 'with qualifier' do
      before(:each) do
        @token = Query::Token.processed('sp:qualifier')
      end
      it 'should return the qualifier' do
        @token.user_defined_category_name.should == :specific
      end
    end
    context 'without qualifier' do
      before(:each) do
        @token = Query::Token.processed('noqualifier')
      end
      it 'should return nil' do
        @token.user_defined_category_name.should == nil
      end
    end
  end

  describe "split" do
    def self.it_should_split text, expected_result
      it "should split #{expected_result} from #{text}" do
        Query::Token.new('any').send(:split, text).should == expected_result
      end
    end
    it_should_split ':',                 [nil,        '']
    it_should_split 'vorname:qualifier', ['vorname', 'qualifier']
    it_should_split 'with:qualifier',    ['with',    'qualifier']
    it_should_split 'without qualifier', [nil,       'without qualifier']
    it_should_split 'name:',             [nil,       'name']
    it_should_split ':broken qualifier', ['',        'broken qualifier']
    it_should_split '',                  [nil,       '']
    it_should_split 'fn:text',           ['fn',      'text']
  end

  describe 'partial=' do
    context 'partial nil' do
      before(:each) do
        @token = Query::Token.new 'text'
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
        @token = Query::Token.processed 'text*'
      end
      it 'should not set partial' do
        @token.partial = false

        @token.instance_variable_get(:@partial).should be_true
      end
    end
  end

  describe 'partialize!' do
    it 'should not partialize a token if the text ends with "' do
      token = Query::Token.processed 'text"'

      token.instance_variable_get(:@partial).should be_false
    end
    it 'should partialize a token if the text ends with *' do
      token = Query::Token.processed 'text*'

      token.instance_variable_get(:@partial).should be_true
    end
    it 'should not partialize a token if the text ends with ~' do
      token = Query::Token.processed 'text~'

      token.instance_variable_get(:@partial).should be_nil
    end
  end

  describe "processed" do
    it 'should remove *' do
      token = Query::Token.processed 'text*'

      token.text.should == 'text'
    end
    it 'should remove ~' do
      token = Query::Token.processed 'text~'

      token.text.should == 'text'
    end
    it 'should remove "' do
      token = Query::Token.processed 'text"'

      token.text.should == 'text'
    end
    it "should pass on a processed text" do
      Query::Token.processed('text').text.should == 'text'
    end
  end

end