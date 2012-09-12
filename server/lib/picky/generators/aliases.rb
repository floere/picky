# Removes and reinstalls convenience generator accessors.
#
module Picky
  remove_const :Partial if defined? Partial
  Partial = Generators::Partial

  remove_const :Similarity if defined? Similarity
  Similarity = Generators::Similarity

  remove_const :Weights if defined? Weights
  Weights = Generators::Weights
end