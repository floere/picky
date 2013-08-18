module Picky

  # Helper methods for measuring, benchmarking, logging.
  #
  module Helpers
    module Measuring

      # Returns a duration in seconds.
      #
      def timed
        time_begin = Time.new

        yield

        (Time.new - time_begin).to_f
      end
      
      def mark_strings
        @__strings = ObjectSpace.each_object(String).to_a
      end
      def diff_strings
        now_hash = Hash.new 0
        now = ObjectSpace.each_object(String).to_a
        now.each { |word| now_hash[word] += 1 }
        
        @__strings.each do |word|
          now_hash[word] -= 1
        end
        
        puts
        p now_hash.select { |_, v| v > 0 }
        puts
      end

    end
  end

end