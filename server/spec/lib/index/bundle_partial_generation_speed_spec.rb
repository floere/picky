require 'spec_helper'

describe Index::Bundle do

  before(:each) do
    @category         = stub :category, :name => :some_category
    @type             = stub :type, :name => :some_type
    @partial_strategy = Cacher::Partial::Subtoken.new :down_to => 1
    @full             = Index::Bundle.new :some_name, @category, @type, @partial_strategy, nil, nil
  end

  def generate_random_keys amount
    alphabet = ('a'..'z').to_a
    (1..amount).to_a.collect! do |n|
      Array.new(20).collect! { alphabet[rand(26)] }.join.to_sym
    end
  end
  def generate_random_ids amount
    (1..amount).to_a.collect! do |_|
      Array.new(rand(100)+5).collect! do |_|
        rand(5_000_000)
      end
    end
  end

  describe 'speed' do
    context 'medium arrays' do
      before(:each) do
        random_keys  = generate_random_keys 500
        random_ids   = generate_random_ids  500
        @full.index = Hash[random_keys.zip(random_ids)]
      end
      it 'should be fast' do
        performance_of do
          @full.generate_partial
        end.should < 0.2
      end
    end
  end

end