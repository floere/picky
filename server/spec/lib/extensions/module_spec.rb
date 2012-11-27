require 'spec_helper'

describe Module do

  describe 'each_forward' do
    context "with correct params" do
      let(:klass) do
        Class.new do

          each_forward :bli, :bla, :blu, :to => :@some_enumerable

          def initialize some_enumerable
            @some_enumerable = some_enumerable
          end

        end
      end
      it 'should send each a bli' do
        bli = stub :bli
        delegating = klass.new [bli, bli, bli, bli]

        bli.should_receive(:bli).exactly(4).times

        delegating.bli
      end
    end
    context "without correct params" do
      it 'should raise an error' do
        lambda do
          Class.new do
            each_forward :bli, :bla, :blu # :to missing
          end
        end.should raise_error(ArgumentError)
      end
    end
  end
  
  describe 'forward' do
    context "with correct params" do
      let(:klass) do
        Class.new do

          forward :bli, :bla, :blu, :to => :@some_thing

          def initialize some_thing
            @some_thing = some_thing
          end

        end
      end
      it 'should send each a bli' do
        bli = stub :bli
        delegating = klass.new bli

        bli.should_receive(:bli).exactly(1).times
        bli.should_receive(:bla).exactly(1).times
        bli.should_receive(:blu).exactly(1).times

        delegating.bli
        delegating.bla
        delegating.blu
      end
    end
    context "without correct params" do
      it 'should raise an error' do
        lambda do
          Class.new do
            forward :bli, :bla, :blu # :to missing
          end
        end.should raise_error(ArgumentError)
      end
    end
  end

end