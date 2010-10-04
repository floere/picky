module DB
  
  # Get a configured Database backend.
  #
  # Options:
  #  Either
  #  * file => 'some/filename.yml' # With an active record configuration.
  #  Or
  #  * The configuration as a hash.
  #
  def self.configured options
    adapter_class = Class.new ActiveRecord::Base
    adapter_class.abstract_class = true
    adapter_class.extend self
    adapter_class.configure options
  end
  
  
  # Configure the AR class.
  #
  # Options:
  #  Either
  #  * file => 'some/filename.yml' # With an active record configuration.
  #  Or
  #  * The configuration as a hash.
  #
  def configure options
    @connection_options = if filename = options[:file]
      File.open(File.join(SEARCH_ROOT, filename)) { |f| YAML::load(f) }
    else
      options
    end
    self
  end
  
  # Connect the AR class.
  #
  def connect
    return if SEARCH_ENVIRONMENT.to_s == 'test' # TODO Unclean.
    raise "Database backend not configured" unless @connection_options
    establish_connection @connection_options
  end
  
end