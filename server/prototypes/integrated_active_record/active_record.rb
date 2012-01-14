module Picky
  # Provides the following to the model.
  #
  # * Adds a Model.search method.
  # * Hooks into after_commit.
  #
  # Example:
  #   
  #
  #
  module ActiveRecord
    
    def self.included model
      model.class.class_eval do
        define_method :updates_picky do |index|
          model.after_commit do
            if destroyed?
              index.remove self.id
            else
              index.replace self
            end
          end
        end
        define_method :searches_picky do |search|
          model.class.class_eval do
            define_method :search do |*args|
              search.search *args
            end
          end
        end
      end
    end
    
    # def initialize index_name = nil, &definition
    #   self.class.class_eval do
    #     define_method :extended do |model|
    #       index_name = index_name || model.name.tableize
    #       index_name = index_name.to_sym
    #       
    #       definition && definition.call # (index_name)
    #       
    #       index = Picky::Indexes[index_name]
    #       search = Picky::Search.new index
    #       
    #       model.class.class_eval do
    #         define_method :search do |*args|
    #           search.search *args
    #         end
    #       end
    #       
    #       model.after_commit do
    #         if destroyed?
    #           index.remove self.id
    #         else
    #           index.replace self
    #         end
    #       end
    #       
    #     end
    #   end
    # 
    # end
    
  end
end