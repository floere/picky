require 'spec_helper'

describe Picky::Helpers::Measuring do
  include Picky::Helpers::Measuring
  
  describe '#timed' do
    it 'should return some duration' do
      timed { 1 + 3 }.should_not be_nil
    end
  end
  
end