module Picky

  class Indexes

    class Memory

      def initialize(*)
        raise <<-MESSAGE

The Picky::Indexes::Memory is not available anymore and has been replaced by Picky::Index.

So instead of

  index = Picky::Indexes::Memory.new :name do
    # your config
  end

use

  index = Picky::Index.new :name do
    # your config
  end

Thanks and sorry for the inconvenience!

MESSAGE
      end

    end

    class Redis

      def initialize(*)
        raise <<-MESSAGE

The Picky::Indexes::Redis is not available anymore and has been replaced by Picky::Index.
(with the addition of a "backend" option)

So instead of

  index = Picky::Indexes::Redis.new :name do
    # your config
  end

use

  index = Picky::Index.new :name do
    backend Picky::Backends::Redis.new
    # your config
  end

Thanks and sorry for the inconvenience!

MESSAGE
      end

    end

  end

end