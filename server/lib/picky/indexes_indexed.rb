module Picky

  # Registers the indexes held at runtime, for queries.
  #
  class Indexes

    instance_delegate :load,
                      :analyze

    each_delegate :load,
                  :reload,
                  :to => :indexes

    # TODO Remove in 4.0.
    #
    def self.reload
      self.instance.reload
    end

  end

end