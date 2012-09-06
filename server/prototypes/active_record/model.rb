require_relative '../model_setup'

# Fake ActiveRecord model.
#
class Model < ActiveRecord::Base
  # Default options just as an example.
  #
  extend Picky::Client::ActiveRecord.configure(host: 'localhost', port: 8080, path: '/')
end