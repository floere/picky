module Configuration
  class Type
    attr_reader :name,
                :source,
                :result_type,
                :after_indexing,
                :ignore_unassigned_tokens
    def initialize name, source, options
      @name                     = name
      @source                   = source
      
      @result_type              = options[:result_type] || name
      @after_indexing           = options[:after_indexing] # Where do I use this?
      @ignore_unassigned_tokens = options[:ignore_unassigned_tokens] || false # TODO Move to query?
    end
    def generate
      Index::Type.new name, source, result_type, ignore_unassigned_tokens
    end
  end
end