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
    def self.included(model)
      model.send :include, Indexing
      model.send :include, Searching
    end

    module Indexing
      def self.included(model)
        model.class.class_eval do
          define_method :updates_picky do |index_or_index_name = model.name.tableize|
            index = index_or_index_name.respond_to?(:to_sym) ?
                    Picky::Indexes[index_or_index_name.to_sym] :
                    index_or_index_name

            model.after_commit do
              if destroyed?
                index.remove self.id
              else
                index.replace self
              end
            end
          end
        end
      end
    end

    module Searching
      def self.included(model)
        model.class.class_eval do
          define_method :searches_picky do |search|
            model.class.class_eval do
              define_method :search do |*args|
                search.search *args
              end
            end
          end
        end
      end
    end
  end
end
