module Picky

  #
  #
  class Index

    delegate :remove,  # aka "delete".
             :add,     # aka "insert".
             :replace, # aka "insert or update".
             :clear_realtime,
             :build_realtime_mapping,
             :to => :categories

    # Add at the end.
    #
    def << thing
      add thing, __method__
    end

    # Add at the beginning (calls add).
    #
    def unshift thing
      add thing, __method__
    end

  end

end