module Picky

  # Registers the indexes held at runtime, for queries.
  #
  class Indexes

    instance_delegate :load,
                      :analyze

    each_delegate :load,
                  :to => :indexes

  end

end