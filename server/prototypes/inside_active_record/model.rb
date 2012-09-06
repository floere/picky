require_relative '../model_setup'

# Fake ActiveRecord model.
#
class Model < ActiveRecord::Base
  
  class << self
    data = Picky::Index.new :models do
      category :name
      category :surname
    end
  
    define_method :replace do |model|
      data.replace model
    end
    
    define_method :remove do |model|
      data.remove model.id
    end
  
    models = Picky::Search.new data
    
    define_method :search do |*args|
      models.search *args
    end
  end
  after_commit do
    if destroyed?
      self.class.remove self
    else
      self.class.replace self
    end
  end
  
end
