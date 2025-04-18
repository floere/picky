require 'picky'
require_relative 'model'

# This will output nothing on the first run,
# but the server will dump/reload even
# when stopping/starting.
#
p 'Expected: Nothing, Nothing OR 1, 1'
p Model.search('surname:mcnama*').ids
p Model.search('picky').ids

picky = Model.new(name: 'Picky', surname: 'McNamara')
picky.save
florian = Model.new(name: 'Florian', surname: 'Hanke')
florian.save
tentacles = Model.new(name: 'Tentacles', surname: 'Jellyfish')
tentacles.save

p 'Expected: 1, 2'
p Model.search('surname:mcnama*').ids
p Model.search('hanke').ids

florian.update_attributes! name: 'Peter', surname: 'Hansmeier'
tentacles.update_attributes! name: 'Roger', surname: 'Braun'

p 'Expected: Nothing, 2, 3'
p Model.search('hanke').ids # Not found anymore.
p Model.search('surname:schies*').ids
p Model.search('roger').ids

florian.destroy
tentacles.destroy

p 'Expected: Nothing, Nothing'
p Model.search('surname:schies*').ids # (Not found anymore)
p Model.search('roger').ids # And out. (Not found anymore)
