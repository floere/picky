require 'spec_helper'

describe Object do
  
  context 'basic object' do
    let(:object) { described_class.new }

    describe 'warn_gem_missing' do
      it 'should warn right' do
        object.should_receive(:warn).once.with "gnorf gem missing!\nTo use gnarble gnarf, you need to:\n  1. Add the following line to Gemfile:\n     gem 'gnorf'\n  2. Then, run:\n     bundle update\n"

        object.warn_gem_missing 'gnorf', 'gnarble gnarf'
      end
    end
  end
  
end