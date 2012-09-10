require_relative '../model_setup'

# Fake ActiveRecord model.
#
class Model < ActiveRecord::Base
  
  def self.data
    @data ||= Picky::Index.new :models do
      category :name
      category :surname
    end
  end
  def self.models
    @models ||= Picky::Search.new data
  end
  
  def self.replace model
    data.replace model
  end
  def self.remove model
    data.remove model.id
  end
  def self.search *args
    models.search *args
  end
  
  after_commit do
    if destroyed?
      self.class.remove self
    else
      self.class.replace self
    end
  end
  
end
