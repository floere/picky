require 'active_record'

# Set up model backend.
#
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)
ActiveRecord::Schema.define(:version => 0) do
  create_table :models, :force => true do |t|
    t.string :name
    t.string :surname
  end
end

# Fake ActiveRecord model.
#
class Model < ActiveRecord::Base
  # Default options just as an example.
  #
  extend Picky::Client::ActiveRecord.configure(host: 'localhost', port: 8080, path: '/')
end