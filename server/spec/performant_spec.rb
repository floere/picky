require 'spec_helper'

describe Performant::Array do
  describe 'memory_efficient_intersect' do
    it 'should intersect empty arrays correctly' do
      arys = [[3, 4], [1, 2, 3], []]

      Performant::Array.memory_efficient_intersect(arys).should == []
    end
    it 'should handle intermediate empty results correctly' do
      arys = [[5, 4], [1, 2, 3], [3, 4, 5, 8, 9]]

      Performant::Array.memory_efficient_intersect(arys).should == []
    end
    it 'should intersect correctly' do
      arys = [[3, 4], [1, 2, 3], [3, 4, 5, 8, 9]]

      Performant::Array.memory_efficient_intersect(arys).should == [3]
    end
    it 'should intersect correctly again' do
      arys = [[1, 2, 3, 5, 6, 7], [3, 4, 5, 6, 7, 8, 9], [3, 4, 5, 6, 7]]
      Performant::Array.memory_efficient_intersect(arys).should == [3, 5, 6, 7]
    end
    it 'should intersect many arrays' do
      arys = [[3, 4, 5, 6, 7], [1, 2, 3, 5, 6, 7], [3, 4, 5, 6, 7, 8, 9], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
              [2, 3, 5, 6, 7, 19], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [2, 3, 5, 6, 7, 19]]

      Performant::Array.memory_efficient_intersect(arys).should == [3, 5, 6, 7]
    end
    it 'should handle random arrays' do
      proto = Array.new(100, 3_500_000)
      arys = [proto.map { |e| rand e }, proto.map { |e| rand e }, proto.map { |e| rand e }]

      Performant::Array.memory_efficient_intersect(arys).should == arys.inject(arys.shift.dup) { |total, _ary|
        total & arys
      }
    end
    it 'should be optimal for 2 small arrays of 50/10_000' do
      arys = [(1..50).to_a, (10_000..20_000).to_a << 7]

      # Brute force.
      #
      performance_of { Performant::Array.memory_efficient_intersect(arys) }.should < 0.001
    end
    it 'should be optimal for 2 small arrays of 50/10_000' do
      arys = [(1..50).to_a, (10_000..20_000).to_a << 7]

      # &
      #
      performance_of do
        arys.inject(arys.shift.dup) do |total, _ary|
          total & arys
        end
      end.should < 0.0015
    end
  end

  describe 'memory_efficient_intersect with symbols' do
    it 'should intersect empty arrays correctly' do
      arys = [%i[c d], %i[a b c], []]

      Performant::Array.memory_efficient_intersect(arys).should == []
    end
    it 'should handle intermediate empty results correctly' do
      arys = [%i[e d], %i[a b c], %i[c d e h i]]

      Performant::Array.memory_efficient_intersect(arys).should == []
    end
    it 'should intersect correctly' do
      arys = [%i[c d], %i[a b c], %i[c d e h i]]

      Performant::Array.memory_efficient_intersect(arys).should == [:c]
    end
    it 'should intersect many arrays' do
      arys = [%i[c d e f g], %i[a b c e f g], %i[c d e f g h i],
              %i[a b c d e f g h i j], %i[b c e f g s], %i[a b c d e f g h i j], %i[b c e f g s]]

      Performant::Array.memory_efficient_intersect(arys).should == %i[c e f g]
    end
    it 'should be optimal for 2 small arrays of 50/10_000' do
      arys = [(:'1'..:'50').to_a, (:'10_000'..:'20_000').to_a]

      # Brute force.
      #
      performance_of { Performant::Array.memory_efficient_intersect(arys) }.should < 0.002
    end
    it 'should be optimal for 2 small arrays of 50/10_000' do
      arys = [(:'1'..:'50').to_a, (:'10_000'..:'20_000').to_a << 7]

      # &
      #
      performance_of do
        arys.inject(arys.shift.dup) do |total, _ary|
          total & arys
        end
      end.should < 0.0015
    end
  end

  describe 'memory_efficient_intersect with strings' do
    it 'should intersect empty arrays correctly' do
      arys = [%w[c d], %w[a b c], []]

      Performant::Array.memory_efficient_intersect(arys).should == []
    end
    it 'should handle intermediate empty results correctly' do
      arys = [%w[e d], %w[a b c], %w[c d e h i]]

      Performant::Array.memory_efficient_intersect(arys).should == []
    end
    it 'should intersect correctly' do
      arys = [%w[c d], %w[a b c], %w[c d e h i]]

      Performant::Array.memory_efficient_intersect(arys).should == ['c']
    end
    it 'should intersect many arrays' do
      arys = [%w[c d e f g], %w[a b c e f g], %w[c d e f g h i], %w[a b c d e f g h i j], %w[b c e f g s],
              %w[a b c d e f g h i j], %w[b c e f g s]]

      Performant::Array.memory_efficient_intersect(arys).should == %w[c e f g]
    end
    it 'should be optimal for 2 small arrays of 50/10_000' do
      arys = [('1'..'50').to_a, ('10000'..'20000').to_a]

      # Brute force - note that it is slower than the Symbols/Integers version.
      #
      performance_of { Performant::Array.memory_efficient_intersect(arys) }.should < 0.0015
    end
    it 'should be optimal for many small arrays of length == 10' do
      arys = [('1'..'10').to_a, ('10'..'20').to_a, ['10'] + ('10000'..'20000').to_a]

      # Brute force - note that it is slower than the Symbols/Integers version.
      #
      performance_of { Performant::Array.memory_efficient_intersect(arys) }.should < 0.0015
    end
    it 'should be optimal for 2 small arrays of 50/10_000' do
      arys = [('1'..'50').to_a, ('10000'..'20000').to_a << 7]

      # &
      #
      performance_of do
        arys.inject(arys.shift.dup) do |total, _ary|
          total & arys
        end
      end.should < 0.0015
    end
  end
end
