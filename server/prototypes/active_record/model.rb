require 'active_support/json'
require_relative 'picky-indexer'

# Fake ActiveRecord model.
#
class Model # < ActiveRecord::Base
  
  # Coded in this way "just for fun".
  #
  include Picky::Indexer(url: '/update')
  
  def initialize id, name, surname
    @id, @name, @surname = id, name, surname
  end
  
  def save
    puts "Saving #{self.to_json}."
    index
    # Save here.
  end
  
end