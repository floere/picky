module Picky
  class Client
    
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
      # Examples:
      #   Picky::Client::ActiveRecord.configure
      #   Picky::Client::ActiveRecord.configure('name', 'surname', index: 'some_index_name')
      #
      # Options:
      #   * index: The index name to save to.
      #   * host: The host where the Picky server is.
      #   * port: The host which the Picky server listens to.
      #   * path: The path the Picky server uses for index updates (use e.f. extend Picky::Sinatra::IndexActions to open up a HTTP indexing interface).
      #   * client: The client to use if you want to pass in your own (host, port, path options will be ignored).
      #   * virtuals: If you want to add index additional attributes that are actually method calls.
      #
      def self.configure *attributes
        new *attributes
      end
      def initialize *attributes
        options = {}
        options = attributes.pop if attributes.last.respond_to?(:to_hash)
        
        # Default path for indexing is '/'.
        #
        client = options[:client] ||
                 (options[:path] ||= '/') && Picky::Client.new(options)      

        virtuals = options[:virtuals] || []
      
        self.class.class_eval do
          index_name = options[:index]
        
          define_method :extended do |model|
            attributes = nil if attributes.empty?
            index_name ||= model.table_name
            
            # Only after the database has actually
            # updated the data do we want to index.
            #
            model.after_commit do |object|
              data = { 'id' => object.id }
              
              if object.destroyed?
                client.remove index_name, data
              else
               ((attributes || object.attributes.keys) + virtuals).each do |attr|
                  data[attr] = object.respond_to?(attr) &&
                               object.send(attr) ||
                               object[attr]
                end

                client.replace index_name, data
              end
            end
          
          end
        end
      
      end
    
    end
    
  end
end
