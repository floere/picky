require 'spec_helper'

describe 'aliases' do

  it 'aliases correctly' do
    Partial.should == Internals::Generators::Partial
  end
  it 'aliases correctly' do
    Similarity.should == Internals::Generators::Similarity
  end
  it 'aliases correctly' do
    Weights.should == Internals::Generators::Weights
  end
  
end