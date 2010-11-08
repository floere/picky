# TODO Remove?
#
module Configuration
  
  # Describes the container for all index configurations.
  #
  class Indexes
    
    attr_reader :types
    
    def initialize
      @types = []
    end
    
    def default_tokenizer options = {}
      Tokenizers::Index.default = Tokenizers::Index.new(options)
    end
    
    # TODO Move this to … where?
    #
    # #
    # #
    # def take_snapshot *type_names
    #   only_if_included_in type_names do |type|
    #     type.take_snapshot
    #   end
    # end
    # def index *type_names
    #   only_if_included_in type_names do |type|
    #     type.index
    #   end
    # end
    # def index_solr *type_names
    #   only_if_included_in type_names do |type|
    #     type.index_solr
    #   end
    # end
    # 
    # #
    # #
    # def only_if_included_in type_names = []
    #   type_names = types.map(&:name) if type_names.empty?
    #   types.each do |type|
    #     next unless type_names.include?(type.name)
    #     yield type
    #   end
    # end
    
  end

end