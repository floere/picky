require 'spec_helper'

describe 'Helpers::Search' do
  include Helpers::Search

  def self.it_should_return_class_for(klass, x)
    it "should return class #{klass} for #{x} items" do
      status_class_for(x).should == klass
    end
  end

  describe "search_status_class_for" do
    it_should_return_class_for :none,  0
    it_should_return_class_for :one,   1
    it_should_return_class_for :few,   2
    it_should_return_class_for :few,   3
    it_should_return_class_for :few,   4
    it_should_return_class_for :few,   5
    it_should_return_class_for :few,   6
    it_should_return_class_for :few,   7
    it_should_return_class_for :some,  8
    it_should_return_class_for :some,  9
    it_should_return_class_for :some, 10
    it_should_return_class_for :some, 11
    it_should_return_class_for :some, 12
    it_should_return_class_for :some, 13
    it_should_return_class_for :some, 14
    it_should_return_class_for :some, 15
    it_should_return_class_for :several, 16
    it_should_return_class_for :several, 17
    it_should_return_class_for :several, 18
    it_should_return_class_for :several, 19
    it_should_return_class_for :several, 20
    it_should_return_class_for :several, 21
    it_should_return_class_for :several, 22
    it_should_return_class_for :several, 23
    it_should_return_class_for :several, 24
    it_should_return_class_for :several, 25
    it_should_return_class_for :many, 26
    it_should_return_class_for :many, 27
    it_should_return_class_for :many, 28
    it_should_return_class_for :many, 29
    # etc.
    it_should_return_class_for :lots, 51
    # etc.
    it_should_return_class_for :too_many, 101
    # etc.
  end

end