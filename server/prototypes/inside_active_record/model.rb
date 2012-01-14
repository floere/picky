require 'active_record'

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
