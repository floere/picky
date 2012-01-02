puts "Start server with 'cd server; thin -p 8080 start'"
puts "(if you haven't done so already)"
puts

require_relative 'model'
require 'picky-client'

client = Picky::Client.new path: '/search'

# This will output nothing on the first run,
# but the server will dump/reload even
# when stopping/starting.
#
p client.search 'surname:mcnama*'
p client.search 'hanke'

Model.new(1, 'Picky', 'McNamara').save
Model.new(2, 'Florian', 'Hanke').save
Model.new(3, 'Tentacles', 'Jellyfish').save

p client.search 'surname:mcnama*'
p client.search 'hanke'