puts "Start server with 'cd server; thin -p 8080 start'"
puts "(if you haven't done so already)"
puts

begin
  require File.expand_path '../../../client/lib/picky-client', __dir__
rescue LoadError
  require 'picky-client'
end
require_relative 'model'

client = Picky::Client.new path: '/search'

# This will output nothing on the first run,
# but the server will dump/reload even
# when stopping/starting.
#
p 'Expected: Nothing, Nothing OR 1, 1'
p client.search 'surname:mcnama*'
p client.search 'picky'

picky = Model.new(name: 'Picky', surname: 'McNamara')
picky.save
florian = Model.new(name: 'Florian', surname: 'Hanke')
florian.save
tentacles = Model.new(name: 'Tentacles', surname: 'Jellyfish')
tentacles.save

p 'Expected: 1, 2'
p client.search 'surname:mcnama*'
p client.search 'hanke'

florian.update_attributes! name: 'Kaspar', surname: 'Schiess'
tentacles.update_attributes! name: 'Roger', surname: 'Braun'

p 'Expected: Nothing, 2, 3'
p client.search 'hanke' # Not found anymore.
p client.search 'surname:schies*'
p client.search 'roger'

florian.destroy
tentacles.destroy

p 'Expected: Nothing, Nothing'
p client.search 'surname:schies*' # (Not found anymore)
p client.search 'roger' # And out. (Not found anymore)