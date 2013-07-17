module Picky

  #
  #
  class Index

    forward :load,
            :analyze,
            :reindex,
            :to => :categories

    # Define how the results of this index are identified.
    # (Shown in the client, for example)
    #
    # Default is the name of the index.
    #
    def result_identifier result_identifier = nil
      result_identifier ? (@result_identifier = result_identifier) : (@result_identifier || @name)
    end

  end

end