require 'spec_helper'

# We need to load the Statistics file explicitly as the Statistics
# are not loaded with the Loader (not needed in the server, only for script runs).
#
require File.expand_path '../../lib/picky/statistics', __dir__

describe Picky::Statistics do
  let(:stats) { described_class.new }

  describe 'lines_of_code' do
    it 'is correct' do
      stats.lines_of_code(<<~TEXT
        # not a line of code
        class LineOfCode
          # also not a line of code
          def bla
            # not one either
            this is one # this is still one
          end
        end
        # In total, we have 5 LOC.
      TEXT
                         ).should == 5
    end
  end
end
