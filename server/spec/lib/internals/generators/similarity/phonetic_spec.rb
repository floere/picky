# encoding: utf-8
#
require 'spec_helper'

describe Internals::Generators::Similarity::Phonetic do

  it 'raises if you try to use Phonetic directly' do
    expect {
      described_class.new
    }.to raise_error("From Picky 2.0 on you need to use the DoubleMetaphone similarity instead of the Phonetic similarity.")
  end

end