require 'spec_helper'

describe 'aliases' do

  it 'aliases correctly' do
    Partial.should == Generators::Partial
  end
  it 'aliases correctly' do
    Similarity.should == Generators::Similarity
  end
  it 'aliases correctly' do
    Weights.should == Generators::Weights
  end
  
end