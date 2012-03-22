module Picky
  module Sinatra
      
    module IndexActions
      
      # TODO Add customizable path?
      #
      def self.extended base
        base.post '/' do
          index_name = params['index']
          index = Picky::Indexes[index_name.to_sym]
          data = params['data']
          index.replace_from Yajl::Parser.parse(data) if data
        end
        base.delete '/' do
          index_name = params['index']
          index = Picky::Indexes[index_name.to_sym]
          data = Yajl::Parser.parse params['data']
          id = data['id']
          index.remove id if id
        end
      end
      
    end
    
  end
end