# encoding: utf-8
#
require 'spec_helper'

describe CharacterSubstituters do
  before(:each) do
    @substituter = CharacterSubstituters::WestEuropean.new
  end

  # A bit of metaprogramming to help with the myriads of its.
  #
  def self.it_should_substitute(special_character, normal_character)
    it "should substitute #{special_character} with #{normal_character}" do
      @substituter.substitute(special_character).should == normal_character
    end
  end
  def self.it_should_not_substitute(special_character)
    it "should not substitute #{special_character}" do
      @substituter.substitute(special_character).should == special_character
    end
  end
  
  # Speed spec at the top since the order of the describes made the
  # speed spec trip. And not on mushrooms either.
  #
  describe "speed" do
    it "is fast" do
      result = performance_of { @substituter.substitute('ä') }
      result.should < 0.00009
    end
    it "is fast" do
      result = performance_of { @substituter.substitute('abcdefghijklmnopqrstuvwxyz1234567890') }
      result.should < 0.00015
    end
  end

  describe "normal characters" do
    it_should_not_substitute('abcdefghijklmnopqrstuvwxyz1234567890')
  end

  describe "situations" do
    it_should_substitute 'Peter Müller', 'Peter Mueller'
    it_should_substitute 'Lüchinger', 'Luechinger'
    # it_should_substitute 'LÜCHINGER', 'LUECHINGER'
  end

  describe "umlauts" do
    it_should_substitute 'ä', 'ae'
    it_should_substitute 'Ä', 'Ae'
    it_should_substitute 'ë', 'e'
    it_should_substitute 'Ë', 'E'
    it_should_substitute 'ï', 'i'
    it_should_substitute 'Ï', 'I'
    it_should_substitute 'ö', 'oe'
    it_should_substitute 'Ö', 'Oe'
    it_should_substitute 'ü', 'ue'
    it_should_substitute 'Ü', 'Ue'
  end

  describe "acute" do
    it_should_substitute 'á', 'a'
    it_should_substitute 'Á', 'A'
    it_should_substitute 'é', 'e'
    it_should_substitute 'É', 'E'
    it_should_substitute 'í', 'i'
    it_should_substitute 'ó', 'o'
  end

  describe "grave" do
    it_should_substitute 'à', 'a'
    it_should_substitute 'À', 'A'
    it_should_substitute 'è', 'e'
    it_should_substitute 'È', 'E'
    it_should_substitute 'ì', 'i'
    it_should_substitute 'ò', 'o'
  end

  describe "circonflex" do
    it_should_substitute 'â', 'a'
    it_should_substitute 'ê', 'e'
    it_should_substitute 'Ê', 'E'
    it_should_substitute 'î', 'i'
    it_should_substitute 'Î', 'I'
    it_should_substitute 'ô', 'o'
    it_should_substitute 'Ô', 'O'
    it_should_substitute 'û', 'u'
  end

  describe "cedilla" do
    it_should_substitute 'ç', 'c'
    it_should_substitute 'Ç', 'C'
  end

  describe "ligatures" do
    it_should_substitute 'ß', 'ss'
    # it_should_substitute 'Æ', 'AE'
  end

  describe "norse" do
    # it_should_substitute 'ø', 'o'
    it_should_substitute 'å', 'a'
    it_should_substitute 'Å', 'A'
  end
  
  describe "diacritic" do
    it_should_substitute 'ñ', 'n'
  end

end