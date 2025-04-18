require 'spec_helper'

require 'text'

describe Picky::Generators::Similarity::Phonetic do
  it "raises when you don't have the text gem" do
    instance = Class.new(described_class).allocate

    instance.should_receive(:require).at_least(1).and_raise LoadError

    Picky.logger.should_receive(:warn).once.with <<~EXPECTED
      Warning: text gem missing!
      To use a phonetic Similarity, you need to:
        1. Add the following line to Gemfile:
           gem 'text'
           or
           require 'text'
           for example at the top of your app.rb file.
        2. Then, run:
           bundle update
    EXPECTED

    instance.should_receive(:exit).once.with 1

    instance.send :initialize
  end

  describe 'prioritize' do
    let(:phonetic) { described_class.allocate }
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 2

      ary = %i[a b c]
      phonetic.prioritize ary, :b

      ary.should == %i[b a]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 2

      ary = %i[aaa aa aaaa]
      phonetic.prioritize ary, :aaa

      ary.should == %i[aaa aa]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 3

      ary = %i[aaa aa aaaa]
      phonetic.prioritize ary, :aaa

      ary.should == %i[aaa aa aaaa]
    end
    it 'sorts correctly' do
      ary = %i[aaa aaaaaa aa]

      ary.sort_by_levenshtein! :aaaaa

      ary.should == %i[aaaaaa aaa aa]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 3

      ary = %i[aaaaaa aa a]
      phonetic.prioritize ary, :aaa

      ary.should == %i[aa a aaaaaa]
    end
    it 'sorts correctly (longer first)' do
      phonetic.instance_variable_set :@amount, 3

      ary = %i[aaaaa aaa a]
      phonetic.prioritize ary, :aaa

      ary.should == %i[aaa aaaaa a]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 3

      ary = %i[aaaaa aa]
      phonetic.prioritize ary, :aaa

      ary.should == %i[aa aaaaa]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 3

      ary = [:aaa]
      phonetic.prioritize ary, :aaa

      ary.should == [:aaa]
    end
    it 'sorts correctly' do
      phonetic.instance_variable_set :@amount, 1

      ary = %i[a aa aaa]
      phonetic.prioritize ary, :aaa

      ary.should == [:aaa]
    end
  end
end
