module Picky
  module Sinatra
      
    module IndexActions
      
      def self.extended base
        base.post '/' do
          index_name = params['index']
          index = Picky::Indexes[index_name.to_sym] # Get the right index from the indexes.
          index.replace_from params['data']
        end
        
        # TODO delete etc.
      end
      
    end
    
  end
end