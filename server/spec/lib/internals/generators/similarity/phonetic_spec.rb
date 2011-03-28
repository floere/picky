# encoding: utf-8
#
require 'spec_helper'

describe Internals::Generators::Similarity::Phonetic do

  it 'raises if you try to use Phonetic directly' do
    expect {
      described_class.new
    }.to raise_error("In Picky 2.0+, the Similarity::Phonetic has been renamed to Similarity::DoubleMetaphone.")
  end

end