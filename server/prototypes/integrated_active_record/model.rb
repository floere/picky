require 'active_record'
require_relative 'active_record'

# Set up model backend.
#
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)
ActiveRecord::Schema.define(:version => 0) do
  create_table :models, :force => true do |t|
    t.string :name
    t.string :surname
  end
end

# Fake ActiveRecord model.
#
class Model < ActiveRecord::Base
  extend(Picky::ActiveRecord.new(:models) do
    Picky::Index.new :models do
      category :name
      category :surname
    end
  end)
end
