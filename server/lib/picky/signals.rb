# TODO Should actually be set in the master?
#
Signal.trap 'USR1' do
  Loader.reload
end
# Signal.trap 'USR2' do
#   Indexes.reload
# end
# Signal.trap 'INT' do
#   exit!
# end