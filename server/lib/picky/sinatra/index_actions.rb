module Picky
  module Sinatra
      
    module IndexActions
      
      def self.extended base
        # Updates the given item and returns HTTP codes:
        #  * 200 if the index has been updated or no error case has occurred.
        #  * 404 if the index cannot be found.
        #  * 400 if no data or item id has been provided in the data.
        #
        # Note: 200 returns no data yet.
        #
        base.post '/' do
          index_name = params['index']
          begin
            index = Picky::Indexes[index_name.to_sym]
            data = params['data']
            return 400 unless data
            data && index.replace_from(Yajl::Parser.parse data) && 200
          rescue IdNotGivenException
            400
          rescue StandardError
            404
          end
        end
        
        # Deletes the given item and returns:
        #  * 200 if the index has been updated or no error case has occurred.
        #  * 404 if the index cannot be found.
        #  * 400 if no data or item id has been provided in the data.
        #
        # Note: 200 returns no data yet.
        #
        base.delete '/' do
          index_name = params['index']
          begin
            index = Picky::Indexes[index_name.to_sym]
            data = Yajl::Parser.parse params['data']
            id = data['id']
            id ? index.remove(id) && 200 : 400
          rescue StandardError
            404
          end
        end
      end
      
    end
    
  end
end