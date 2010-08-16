module Helpers
  module Search

    def status_class_for(results_count)
      case results_count
        when (51..100)
          :lots
        when (26..50)
          :many
        when (16..25)
          :several
        when (8..15)
          :some
        when (2..7)
          :few
        when 1
          :one
        when 0
          :none
        else
          :too_many
      end
    end

  end

end