require 'rspec/matchers' rescue nil
if defined? RSpec::Matchers
  RSpec::Matchers.define :have_categories do |*expected|

    match do |results|
      extract_categories(actual) == expected
    end

    failure_message_for_should do |results|
      "expected categories #{extract_categories(results)} to be named and ordered as #{expected}"
    end

    failure_message_for_should_not do |results|
      "expected categories #{extract_categories(results)} not to be named and ordered as #{expected}"
    end

    description do
      "be categories named and ordered as #{expected}"
    end

    def extract_categories results
      results.allocations.map do |allocation|
        allocation[3].map { |combination| combination[0] }
      end
    end

  end
end