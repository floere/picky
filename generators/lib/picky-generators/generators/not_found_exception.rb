module Picky
  
  module Generators
    
    # Thrown when no generator for the command
    #   picky <command> <options>
    # is found.
    #
    class NotFoundException < StandardError # :nodoc:all

      def initialize selector
        super usage + possible_commands(selector.types)
      end

      def usage
        "\nUsage:\n" +
        "picky generate <type> <params>\n" +
        ?\n
      end

      def possible_commands types
        "Possible commands:\n" +
        types.map do |name, klass_params|
          result = "picky generate #{name}"
          _, params = *klass_params
          result << ' ' << [*params].map { |param| "<#{param}>" }.join(' ') if params
          result
        end.join(?\n) + ?\n
      end

    end
    
  end
  
end