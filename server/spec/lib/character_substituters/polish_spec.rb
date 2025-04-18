# encoding: utf-8
#
require 'spec_helper'

describe Picky::CharacterSubstituters::Polish do

  let(:substituter) { described_class.new.tap { |s| s.substitute '' } }

  # A bit of metaprogramming to help with the myriads of its.
  #
  def self.it_should_substitute(special_character, normal_character)
    it "should substitute #{special_character} with #{normal_character}" do
      substituter.substitute(special_character).should == normal_character
    end
  end
  def self.it_should_not_substitute(special_character)
    it "should not substitute #{special_character}" do
      substituter.substitute(special_character).should == special_character
    end
  end

  # Speed spec at the top since the order of the describes made the
  # speed spec trip. And not on mushrooms either.
  #
  describe 'speed' do
    it 'is fast' do
      substituter.substitute 'ą' # Prerun
      result = performance_of { substituter.substitute('ą') }
      result.should < 0.0002
    end
    it 'is fast' do
      result = performance_of { substituter.substitute('abcdefghijklmnopqrstuvwxyz1234567890') }
      result.should < 0.00015
    end
  end

  describe 'to_s' do
    it 'outputs correctly' do
      substituter.to_s.should == 'Picky::CharacterSubstituters::Polish'
    end
  end

  describe 'normal characters' do
    it_should_not_substitute('abcdefghijklmnopqrstuvwxyz1234567890')
  end

  describe 'situations' do
    it_should_substitute 'Michał Prawda', 'Michal Prawda'
    it_should_substitute 'Brzęczyszczykiewicz', 'Brzeczyszczykiewicz'
  end

  describe 'diacritics' do
    #ĄąĘęĆćŁłŃńŚśÓóŹźŻż
    it_should_substitute 'ą', 'a'
    it_should_substitute 'Ą', 'A'
    it_should_substitute 'ę', 'e'
    it_should_substitute 'Ę', 'E'
    it_should_substitute 'ć', 'c'
    it_should_substitute 'Ć', 'C'
    it_should_substitute 'ł', 'l'
    it_should_substitute 'Ł', 'L'
    it_should_substitute 'ń', 'n'
    it_should_substitute 'Ń', 'N'
    it_should_substitute 'ś', 's'
    it_should_substitute 'Ś', 'S'
    it_should_substitute 'ó', 'o'
    it_should_substitute 'Ó', 'O'
    it_should_substitute 'ź', 'z'
    it_should_substitute 'Ź', 'Z'
    it_should_substitute 'ż', 'z'
    it_should_substitute 'Ż', 'Z'
  end

end
