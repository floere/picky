require File.expand_path('../../../spec_helper', __FILE__)

require 'picky-indexes/rust/array'

describe Rust::Array do
  
  it 'can be created' do
    described_class.new
  end
  
  it 'finalizable (will run after specs)' do
    ohai = described_class.new
    ohai = nil
  end
  
  let(:empty) { described_class.new }
  let(:array) { described_class.new }
  
  describe 'with some elements' do
    before(:each) do
      5.times { |i| array << i }
    end
    
    describe '#each' do
      it 'handles an empty array' do
        empty.each { raise }
      end
      it 'is correct' do
        result = []
        array.each { |i| result << i }
        result.assert == [0,1,2,3,4]
      end
    end
    describe '#map' do
      it 'handles an empty array' do
        empty.map { raise }
      end
      it 'is correct' do
        expected = described_class.new
        expected << 0 << 2 << 4 << 6 << 8
        
        array.map { |i| i*2 }.assert == expected
      end
    end
    describe '#find' do
      it 'is correct' do
        array.find { |i| i.odd? }.assert == 1
      end
    end
    describe '#first' do
      # it 'handles an empty array' do
      #   empty.first.assert == nil
      # end
      it 'is correct' do
        array.first.assert == 0
      end
    end
    describe '#first (with amount)' do
      let(:large) do
        ary = described_class.new()
        (0..30).each do |i|
          ary << i
        end
        ary
      end
      it 'is correct' do
        expected = described_class.new
        (0..19).each { |i| expected << i }
      
        large.first(20).assert == expected
      end
      it 'has no trouble with a too long array' do
        large.first(100_000).assert == large
      end
    end
    describe '#last' do
      # it 'handles an empty array' do
      #   empty.last.assert == nil
      # end
      it 'is correct' do
        array.last.assert == 4
      end
    end
    describe '#length' do
      it 'handles an empty array' do
        empty.length.assert == 0
      end
      it 'is correct' do
        array.length.assert == 5
      end
    end
    describe '#size' do
      it 'handles an empty array' do
        empty.size.assert == 0
      end
      it 'is correct' do
        array.size.assert == 5
      end
    end
    describe '#intersect' do
      it 'handles a left empty array' do
        empty.intersect(array).assert == Rust::Array.new
      end
      it 'handles a right empty array' do
        array.intersect(empty).assert == Rust::Array.new
      end
      it 'is correct' do
        array.intersect(array).assert == array
      end
      it 'is correct' do
        a1 = Rust::Array.new
        a1 << 2 << 3 << 4
        
        a2 = Rust::Array.new
        a2 << 3 << 4 << 5
        
        expected = Rust::Array.new
        expected << 3 << 4
        
        a1.intersect(a2).assert == expected
        a2.intersect(a1).assert == expected
      end
      # it 'is performant' do
      #   a1 = described_class.new
      #   a2 = described_class.new
      #
      #   10_000.times do |i|
      #     a1 << i
      #     a2 << i
      #   end
      #
      #   t = Time.now
      #   a1.intersect(a2).assert a1
      #   p Time.now - t
      # end
    end
    describe '#sort_by!' do
      it 'is correct with identity' do
        array.sort_by! { |x| x }.assert == array
      end
      it 'is correct' do
        expected = Rust::Array.new
        expected << 4 << 3 << 2 << 1 << 0
        
        array.sort_by! do |x|
          -x
        end.assert == expected
      end
      it 'fails non-gracefully' do
        expected = Rust::Array.new
        expected << 4 << 3 << 2 << 1 << 0
        
        expect do
          array.sort_by! do |x|
            -100_000_000_000_000
          end
        end.to raise_error(RangeError)
      end
    end
    describe '#slice!' do
      it 'handles an empty array' do
        empty.slice!(1,1).assert == nil
      end
      it 'is correct' do
        expected = Rust::Array.new
        expected << 0 << 1 << 3 << 4
        
        array.slice!(2,1)
        
        array.assert == expected
      end
      it 'returns the deleted object(s)' do
        expected = Rust::Array.new
        expected << 2 << 3
        
        array.slice!(2,2).assert == expected
      end
      it 'handles a too large amount' do
        expected = Rust::Array.new
        expected << 0 << 1 << 2 << 3 << 4
        
        array.slice!(0,20).assert == expected
      end
    end
    describe '#empty?' do
      it 'handles empty arrays' do
        empty.assert.empty?
      end
      it 'handles normal arrays' do
        array.refute.empty?
      end
    end
    describe '#+' do
      it 'handles empty arrays' do
        (empty + empty).assert == empty
      end
      it 'handles normal arrays' do
        (empty + array).assert == array
      end
      it 'handles normal arrays' do
        (array + empty).assert == array
      end
      it 'handles normal arrays' do
        expected = described_class.new
        expected << 0 << 1 << 2 << 3 << 4 << 0 << 1 << 2 << 3 << 4
        
        (array + array).assert == expected
      end
      it 'handles Arrays' do
        (empty + []).assert == empty
      end
      it 'handles Arrays' do
        expected = described_class.new
        expected << 1 << 2 << 3 << 4 << 5
        
        (empty + [1, 2, 3, 4, 5]).assert == expected
      end
    end
    describe '#-' do
      it 'handles empty arrays' do
        (empty - empty).assert == empty
      end
      it 'handles normal arrays' do
        (empty - array).assert == empty
      end
      it 'handles normal arrays' do
        (array - empty).assert == array
      end
      it 'handles normal arrays' do
        (array - array).assert == empty
      end
    end
    describe '#==' do
      it 'handles empty arrays' do
        Rust::Array.new.assert == Rust::Array.new
      end
      it 'handles empty arrays' do
        empty.assert == empty.dup
      end
      it 'handles empty arrays' do
        assert !(empty == array)
      end
      it 'handles empty arrays' do
        assert !(array == empty)
      end
      it 'handles normal arrays' do
        assert array == array.dup
      end
      it 'handles normal arrays' do
        shorty = Rust::Array.new
        shorty << 1
        
        assert !(array == shorty)
      end
      it 'handles a different class instance' do
        assert !(empty == []) 
      end
    end
    describe '#==' do
      it 'handles empty arrays' do
        Rust::Array.new.assert == Rust::Array.new
      end
      it 'handles empty arrays' do
        empty.assert == empty.dup
      end
      it 'handles empty arrays' do
        assert !(empty == array)
      end
      it 'handles empty arrays' do
        assert !(array == empty)
      end
      it 'handles normal arrays' do
        assert array == array.dup
      end
      it 'handles normal arrays' do
        shorty = Rust::Array.new
        shorty << 1
        
        assert !(array == shorty)
      end
    end
    describe '#include' do
      it 'works' do
        empty.refute.include?(0)
      end
      it 'works' do
        array.assert.include?(0)
      end
      it 'works' do
        array.assert.include?(4)
      end
      it 'works' do
        array.refute.include?(5)
      end
    end
    describe '#dup' do
      it 'works correctly' do
        dupped = array.dup
        
        dupped.shift
        
        dupped.size.assert == array.size - 1
      end
      it 'works correctly' do
        dupped = array.dup
        
        dupped.shift(5)
        
        dupped.assert == empty
      end
    end
    describe '#inspect' do
      it 'works with empty arrays' do
        empty.inspect.assert == '[]'
      end
      it 'works for a normal array' do
        array.inspect.assert == '[0, 1, 2, 3, 4]'
      end
    end
  end
  
  describe '#<<' do
    it 'works' do
      array << 1
    end
    it 'returns the array' do
      expected = Rust::Array.new
      expected << 1

      result = array << 1
      expected.assert == result
    end
    # it 'actually appends' do
    #   # [].assert == array
    #
    #   array << 1
    #
    #   # assert [1] == array
    # end
  end
  describe '#shift' do
    # it 'works with empty arrays' do
    #   empty.shift.assert == nil
    # end
    it 'works' do
      array << 7
      array << 8
      array << 9
      
      array.shift.assert == 7
      array.shift.assert == 8
      array.shift.assert == 9
    end
  end
  describe '#unshift' do
    it 'works with empty arrays' do
      expected = Rust::Array.new
      expected << 7
      
      empty.unshift(7).assert == expected
    end
    it 'works with normal arrays' do
      expected = Rust::Array.new
      expected << 7 << 1 << 2
      
      array << 1 << 2
      array.unshift(7).assert == expected
    end
  end
  
  describe '#reject' do
    let(:array) do
      ary = described_class.new()
      (0..10).each do |i|
        ary << i
      end
      ary
    end
    it 'sorts correctly' do
      expected = described_class.new
      [1,3,5,7,9].each { |i| expected << i }
      
      array.reject { |i| i.even? }.assert == expected
    end
  end
  describe '#reject' do
    let(:array) do
      ary = described_class.new
      (0..10).each { |i| ary << i }
      ary
    end
    it 'transforms correctly' do
      array.to_ary.assert == (0..10).to_a
    end
  end
  
  describe '#sort_by' do
    let(:large) do
      ary = described_class.new()
      (0..999).each do |i|
        ary << i
      end
      ary
    end
    it 'sorts correctly' do
      expected = described_class.new
      999.downto(980).each { |i| expected << i }
      
      large.sort_by! { |i| -i }
      large.first(20).assert == expected
    end
  end
  
  describe 'complex use case' do
    it 'works' do
      array << 7
      array << 8
      array << 9
      array.shift.assert == 7
      array << 10
      array.shift(2).assert == Rust::Array.new << 8 << 9
      array.assert == Rust::Array.new << 10
      array << 11
      array << 12
      array.unshift 9
      array.assert == Rust::Array.new << 9 << 10 << 11 << 12
      array.assert.include?(9)
      combined = array + Rust::Array.new << 13
      combined.assert == Rust::Array.new << 9 << 10 << 11 << 12 << 13
      array = combined - (Rust::Array.new << 10 << 11 << 12)
      array.assert == Rust::Array.new << 9 << 13
      array << 14
      array.slice!(1,1)
      array.assert == Rust::Array.new << 9 << 14
      array << 15
      intersected = array.intersect(Rust::Array.new << 14 << 15 << 16)
      intersected.assert == Rust::Array.new << 14 << 15
      intersected.sort_by! { |x| -x }
      intersected.assert == Rust::Array.new << 15 << 14
    end
    it 'handles large numbers' do
      array << 10_000
      array << 10_001
      array << 10_002
      array.shift.assert == 10_000
      
      array.sort_by! { |x| -x }
      array.assert == Rust::Array.new << 10_002 << 10_001
    end
  end
  
end