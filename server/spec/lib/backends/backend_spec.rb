require 'spec_helper'

describe Picky::Backends::Backend do

    describe 'extract_lambda_or' do
      it 'returns a given non-lambda' do
        backend.extract_lambda_or(:thing).should == :thing
      end
      it 'calls a given lambda with the given args' do
        lam = ->() do
          :lam
        end

        backend.extract_lambda_or(lam).should == :lam
      end
      it 'calls a given lambda with the given args' do
        lam = ->(arg1) do
          arg1.should == 1
          :lam
        end

        backend.extract_lambda_or(lam, 1).should == :lam
      end
      it 'calls a given lambda with the given args' do
        lam = ->(arg1, arg2) do
          arg1.should == 1
          arg2.should == 2
          :lam
        end

        backend.extract_lambda_or(lam, 1, 2).should == :lam
      end
    end
  end

end