module Picky
  class Client
    
    # TODO Rename?
    #
    # Parameters:
    #   * index_name: An index that exists in the Picky server.
    #   * data: A hash in the form of { :id => 1234, :attr1 => 'attr1', :attr2 => 'attr2', ... }.
    #
    def replace index_name, data
      send_off Net::HTTP::Post.new(self.path), index_name, data
    end
    
    # TODO Rename?
    #
    # Parameters:
    #   * index_name: An index that exists in the Picky server.
    #   * data: A hash in the form of { :id => 1234 }.
    #
    def remove index_name, data
      send_off Net::HTTP::Delete.new(self.path), index_name, data
    end
    
    # Sends a request to the Picky server.
    #
    # Note: Data is JSON encoded.
    #
    def send_off request, index_name, data
      request.form_data = { :index => index_name, :data => ActiveSupport::JSON.encode(data) }
      Net::HTTP.new(self.host, self.port).start { |http| http.request request }
    end

  end
end