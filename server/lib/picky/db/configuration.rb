class DB < ActiveRecord::Base
  
  self.abstract_class = true
  
  #
  #
  def self.configure options = {}
    @connection_options = if filename = options[:file]
      File.open(File.join(SEARCH_ROOT, filename)) { |f| YAML::load(f) }
    else
      options
    end
    self
  end
  
  #
  #
  def self.connect
    return if SEARCH_ENVIRONMENT.to_s == 'test'
    establish_connection @connection_options
  end
  
end