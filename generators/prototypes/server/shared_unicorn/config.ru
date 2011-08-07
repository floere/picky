# Require the gem. This loads the search framework.
#
require 'picky'

# Load your application. This requires the following files in
#
#  * lib/initializers/*.rb
#  * lib/tokenizers/*.rb
#  * lib/indexers/*.rb
#  * lib/query/*.rb
#
#  * app/logging.rb
#  * app/application.rb
#
# (in that order).
#
Picky::Loader.load_application

# Load the indexes into the memory.
#
Picky::Indexes.reload

# TODO Decide if you want to use the Unicorn killing trick. (Good with large data sets)
#
# Use Harakiri middleware to kill worker child after X requests.
#
# Works only with web servers that fork worker children and which
# fork new children, like for example Unicorn.
#
# Rack::Harakiri.after = 50
# use Rack::Harakiri

# Start accepting requests.
#
# Note: Needs to be the same constant name as in app/application.rb.
#
run PickySearch