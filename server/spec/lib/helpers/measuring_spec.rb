require 'spec_helper'

describe Helpers::Measuring do
  include Helpers::Measuring

  describe "#timed" do
    it "should return some duration" do
      timed { 1 + 3 }.should_not be_nil
    end
  end

  describe "#log_performance" do
    it "should log" do
      log_performance('hello') { 10000*10000 }
    end
  end

end