require 'spec_helper'

describe Picky::API::Search::Boost do
  let(:object) do
    Class.new do
      include Picky::API::Search::Boost
    end.new
  end
  context 'boost_for' do
    context 'with a Hash' do
      it 'returns a boosts object' do
        combinations = [
          double(:combination, category_name: :bla)
        ]

        object.extract_boosts([:bla] => +7.77).boost_for(combinations).should == 7.77
      end
    end
    context 'with a boosts object' do
      let(:booster) do
        Class.new do
          def boost_for(_whatever)
            7.0
          end
        end.new
      end
      it 'returns a boosts object' do
        object.extract_boosts(booster).boost_for(:anything).should == 7.0
      end
    end
    context 'invalid weight' do
      it 'raises with a nice error message' do
        expect do
          object.extract_boosts Object.new
        end.to raise_error(<<~ERROR)
          boost options for a Search should be either
          * for example a Hash { [:name, :surname] => +3 }
          or
          * an object that responds to #boost_for(combinations) and returns a boost float
        ERROR
      end
    end
  end
end
