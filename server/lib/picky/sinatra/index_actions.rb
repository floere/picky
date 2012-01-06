module Picky
  module Sinatra
      
    module IndexActions
      
      def self.extended base
        base.post '/' do
          index_name = params[:index]
          index = Picky::Indexes[index_name.to_sym]
          data = params[:data]
          index.replace_from data if data
        end
        base.delete '/' do
          index_name = params[:index]
          index = Picky::Indexes[index_name.to_sym]
          id = params[:data][:id]
          index.remove id if id
        end
      end
      
    end
    
  end
end