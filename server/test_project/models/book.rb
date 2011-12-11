class Book < ActiveRecord::Base; end
Book.establish_connection YAML.load(File.open('db.yml'))