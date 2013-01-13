module Picky

  #
  #
  class Index

    forward :remove,  # aka "delete".
            :add,     # aka "insert".
            :replace, # aka "delete then insert".
            :update,
            :replace_from,
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