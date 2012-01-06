module Picky
  module Client
    
    # An ActiveRecord integration that uses the
    # Picky HTTP client to send index updates
    # back to a Picky server (usually Sinatra).
    # 
    # Examples:
    #   # Note that the Person will
    #   # be indexed in three indexes.
    #   #
    #   class Person < ActiveRecord::Base
    #     extend Picky::ActiveRecord.new # All attributes will be sent to index "people".
    #     extend Picky::ActiveRecord.new('name') # Only the name will be sent to index "people".
    #     extend Picky::ActiveRecord.new('surname', index: 'special_index') # Only the surname will be sent to index "special_index".
    #     # Use the given Client to send index data.
    #     #
    #     extend Picky::ActiveRecord.new(client: Picky::Client.new(host: 'localhost', port: '4567', path: '/indexing'))
    #     extend Picky::ActiveRecord.new(host: 'localhost', port: '4567', path: '/indexing')
    #   end
    #
    #   florian = Person.new name: "Florian", surname: "Hanke"
    #   florian.save
    #   florian.update_attributes name: "Peter"
    #
    class ActiveRecord < Module
      
      # Takes an array of indexed attributes/methods
      # and options.
      #
      # Note: See class documentation for a description.
      #
      # Options:
      #   * index: The index name to save to.
      #   * host: The host where the Picky server is.
      #   * port: The host which the Picky server listens to.
      #   * path: The path the Picky server uses for index updates (use e.f. extend Picky::Sinatra::IndexActions to open up a HTTP indexing interface).
      #   * client: The client to use if you want to pass in your own (host, port, path options will be ignored).
      #
      def initialize *attributes
        options = {}
        options = attributes.pop if attributes.last.respond_to?(:to_hash)
        
        # Default path for indexing is '/'.
        #
        client = options[:client] ||
                 (options[:path] ||= '/') && Picky::Client.new(options)      
      
        self.class.class_eval do
          index_name = options[:index]
        
          define_method :extended do |model|
            attributes = nil if attributes.empty?
            index_name ||= model.table_name
          
            model.after_save do |object|
              data = { 'id' => object.id }
            
              (attributes || object.attributes.keys).each do |attr|
                data[attr] = object.respond_to?(attr) &&
                             object.send(attr) ||
                             object[attr]
              end
            
              puts "Saving #{data} to index #{index_name}."
            
              # TODO Actually saving changes by calling the
              # client#index(index_name, data) method.
            end
          
          end
        end
      
      end
    
    end
    
  end
end