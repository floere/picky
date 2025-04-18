require 'spec_helper'

describe 'aliases' do
  it 'aliases correctly' do
    Picky::Partial.should == Picky::Generators::Partial
  end
  it 'aliases correctly' do
    Picky::Similarity.should == Picky::Generators::Similarity
  end
  it 'aliases correctly' do
    Picky::Weights.should == Picky::Generators::Weights
  end
end
