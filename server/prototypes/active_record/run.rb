puts "Start server with 'thin -p 8080 start' (if you haven't done so yet)"

require_relative 'model'

model = Model.new 1, 'Picky', 'McNamara'
model.save

model = Model.new 2, 'Florian', 'Hanke'
model.save

require 'picky-client'

client = Picky::Client.new path: '/search'
p client.search 'hanke'