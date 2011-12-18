require 'spec_helper'

describe Picky::API::Category::Partial do
  let(:object) do
    Class.new do
      include Picky::API::Category::Partial

      def index_name
        :some_index
      end
      def name
        :some_category
      end
    end.new
  end
  context 'extract_partial' do
    context 'with nil' do
      it 'returns the default' do
        object.extract_partial(nil).should == Picky::Partial::Default
      end
    end
    context 'with a partial object' do
      let(:partializer) do
        Class.new do
          def each_partial text
            'tex'
          end
        end.new
      end
      it 'yields the partial' do
        object.extract_partial(partializer).each_partial('whatevs') do |text|
          text.should == 'tex'
        end
      end
    end
    context 'invalid weight' do
      it 'raises with a nice error message' do
        expect {
          object.extract_partial Object.new
        }.to raise_error(<<-ERROR)
partial options for some_index:some_category should be either
* for example a Partial::Substring.new(from: m, to: n), Partial::Postfix.new(from: n), Partial::Infix.new(min: m, max: n) etc.
or
* an object that responds to #each_partial(str_or_sym) and yields each partial
ERROR
      end
    end
  end
end