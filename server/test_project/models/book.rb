class Book < ActiveRecord::Base; end
db_config_path = File.expand_path('../db.yml', __dir__)
Book.establish_connection YAML.load(File.open(db_config_path))