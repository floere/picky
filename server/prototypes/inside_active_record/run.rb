require 'picky'
require_relative 'model'

# This will output nothing on the first run,
# but the server will dump/reload even
# when stopping/starting.
#
p "Expected: Nothing, Nothing OR 1, 1"
p Model.search 'surname:mcnama*'
p Model.search 'picky'

picky = Model.new(name: 'Picky', surname: 'McNamara')
picky.save
florian = Model.new(name: 'Florian', surname: 'Hanke')
florian.save
tentacles = Model.new(name: 'Tentacles', surname: 'Jellyfish')
tentacles.save

p "Expected: 1, 1"
p Model.search 'surname:mcnama*'
p Model.search 'hanke'

florian.update_attributes! name: 'Kaspar', surname: 'Schiess'
tentacles.update_attributes! name: 'Roger', surname: 'Braun'

p "Expected: Nothing, 1, 1"
p Model.search 'hanke' # Not found anymore.
p Model.search 'surname:schies*'
p Model.search 'roger'

florian.destroy
tentacles.destroy

p "Expected: Nothing, Nothing"
p Model.search 'surname:schies*' # (Not found anymore)
p Model.search 'roger' # And out. (Not found anymore)
