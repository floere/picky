require 'spec_helper'

require 'time'

describe Object do

  context 'basic object' do
    let(:object) { described_class.new }

    describe "timed_exclaim" do
      it "should exclaim right" do
        Time.stub! :now => Time.parse('07-03-1977 12:34:56')
        object.should_receive(:exclaim).once.with "12:34:56: bla"

        object.timed_exclaim 'bla'
      end
    end

    describe 'warn_gem_missing' do
      it 'should warn right' do
        Picky.logger.should_receive(:warn).once.with <<-EXPECTED
Warning: gnorf gem missing!
To use gnarble gnarf, you need to:
  1. Add the following line to Gemfile:
     gem 'gnorf'
     or
     require 'gnorf'
     for example at the top of your app.rb file.
  2. Then, run:
     bundle update
EXPECTED
        
        object.warn_gem_missing 'gnorf', 'gnarble gnarf'
      end
    end
  end

  describe 'indented_to_s' do
    describe String do
      let(:string) { String.new("Hello\nTest") }

      it 'indents a default amount' do
        string.indented_to_s.should == "  Hello\n  Test"
      end
      it 'indents twice' do
        string.indented_to_s.indented_to_s.should == "    Hello\n    Test"
      end
      it 'indents correctly' do
        string.indented_to_s(3).should == "   Hello\n   Test"
      end
    end
    describe Array do
      let(:array) { Array.new(["Hello", "Test"]) }

      it 'indents a default amount' do
        array.indented_to_s.should == "  Hello\n  Test"
      end
      it 'indents twice' do
        array.indented_to_s.indented_to_s.should == "    Hello\n    Test"
      end
    end
  end

end