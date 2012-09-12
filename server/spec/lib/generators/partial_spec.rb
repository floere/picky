require 'spec_helper'

describe Picky::Generators::Partial do
  let(:partial) { described_class } # "class", actually a module.
  context 'extract_partial' do
    context 'with nil' do
      it 'returns the default' do
        partial.from(nil).should == Picky::Partial::Default
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
        partial.from(partializer).each_partial('whatevs') do |text|
          text.should == 'tex'
        end
      end
    end
    context 'invalid partial' do
      it 'raises with a nice error message' do
        expect {
          partial.from Object.new
        }.to raise_error(<<-ERROR)
partial options should be either
* for example a Partial::Substring.new(from: m, to: n), Partial::Postfix.new(from: n), Partial::Infix.new(min: m, max: n) etc.
or
* an object that responds to #each_partial(str_or_sym) and yields each partial
ERROR
      end
    end
    context 'invalid partial' do
      it 'raises with a nice error message' do
        expect {
          partial.from Object.new, 'some_index'
        }.to raise_error(<<-ERROR)
partial options for some_index should be either
* for example a Partial::Substring.new(from: m, to: n), Partial::Postfix.new(from: n), Partial::Infix.new(min: m, max: n) etc.
or
* an object that responds to #each_partial(str_or_sym) and yields each partial
ERROR
      end
    end
    context 'invalid partial' do
      it 'raises with a nice error message' do
        expect {
          partial.from Object.new, 'some_index', 'some_category'
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