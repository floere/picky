require 'spec_helper'

describe Module do

  describe 'each_delegate' do
    context "with correct params" do
      before(:each) do
        @klass = Class.new do
          
          each_delegate :bli, :bla, :blu, :to => :@some_enumerable
          
          def initialize some_enumerable
            @some_enumerable = some_enumerable
          end
          
        end
      end
      it 'should send each a bli' do
        bli = stub :bli
        delegating = @klass.new [bli, bli, bli, bli]
        
        bli.should_receive(:bli).exactly(4).times
        
        delegating.bli
      end
    end
    context "without correct params" do
      it 'should send each a bli' do
        lambda do
          Class.new do
            each_delegate :bli, :bla, :blu # :to missing
          end
        end.should raise_error(ArgumentError)
      end
    end
  end
  
end