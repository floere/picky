require 'test_helper'

module Slingshot
  module Model

    class ActiveModelLintTest < Test::Unit::TestCase

      include ActiveModel::Lint::Tests

      def setup
        @model = Gem.new :name => 'Test'
      end

    end

  end
end
