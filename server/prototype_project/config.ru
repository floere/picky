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
Loader.load_application

# Load the data. This loads data from cache files e.g. "some_index/*_index.dump" into Indexes[:some_index]
#
Indexes.load_from_cache

# Use Harakiri middleware to kill unicorn child after X requests.
#
# See http://vimeo.com/12614970 for more info.
#
    Rack::Harakiri.after = 50
use Rack::Harakiri

# Finalize the application and start accepting requests.
#
# Note: Needs to be the same constant name as in app/application.rb.
#
    PickySearch.finalize
run PickySearch