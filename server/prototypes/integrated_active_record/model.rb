require_relative '../model_setup'
require_relative 'active_record'

# Fake ActiveRecord model.
#
class Model < ActiveRecord::Base
  include Picky::ActiveRecord

  index = Picky::Index.new :models do
    category :name
    category :surname
  end

  search = Picky::Search.new index

  updates_picky index # Pass in nothing (uses index name), index name, or an index.
  searches_picky search

  # updates_picky index # Updating multiple indexes.
end
