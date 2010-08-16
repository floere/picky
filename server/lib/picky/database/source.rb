module DB
  
  # This model is needed only to provide the database adapter for the public DB.
  #
  class Source < ActiveRecord::Base
    self.abstract_class = true
    
    def self.connect
      return if SEARCH_ENVIRONMENT.to_s == 'test'
      establish_connection(File.open(File.join(SEARCH_ROOT, 'config/db/source.yml')) {|f| YAML::load(f)})
    end
  end
  
end