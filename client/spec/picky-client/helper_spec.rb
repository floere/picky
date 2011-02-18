require 'spec_helper'

describe Picky::Helper do
  
  describe "cached_interface" do
    it "should return good html" do
      Picky::Helper.cached_interface.should == Picky::Helper.interface
    end
    it "should respect the options" do
      Picky::Helper.cached_interface(:more => 'bla').should_not == Picky::Helper.interface(:more => 'blu')
    end
    it "should return the cached interface" do
      Picky::Helper.cached_interface.object_id.should == Picky::Helper.cached_interface.object_id
    end
    it "should be frozen" do
      Picky::Helper.cached_interface.should be_frozen
    end
  end
  
  describe "input" do
    it "should return good html" do
      Picky::Helper.input.should == "<div class=\"dashboard empty\">\n  <div class=\"feedback\">\n    <div class=\"status\"></div>\n    <input type=\"text\" autocorrect=\"off\" class=\"query\"/>\n    <div class=\"reset\" title=\"clear\"></div>\n  </div>\n  <input type=\"button\" class=\"search_button\" value=\"search\">\n</div>\n"
    end
    it "should return good html" do
      Picky::Helper.input(:button => 'find').should == "<div class=\"dashboard empty\">\n  <div class=\"feedback\">\n    <div class=\"status\"></div>\n    <input type=\"text\" autocorrect=\"off\" class=\"query\"/>\n    <div class=\"reset\" title=\"clear\"></div>\n  </div>\n  <input type=\"button\" class=\"search_button\" value=\"find\">\n</div>\n"
    end
  end
  
  describe "results" do
    it "should return good html" do
      Picky::Helper.input.should == "<div class=\"dashboard empty\">\n  <div class=\"feedback\">\n    <div class=\"status\"></div>\n    <input type=\"text\" autocorrect=\"off\" class=\"query\"/>\n    <div class=\"reset\" title=\"clear\"></div>\n  </div>\n  <input type=\"button\" class=\"search_button\" value=\"search\">\n</div>\n"
    end
    it "should return good html" do
      Picky::Helper.input(:no_results => 'SORRY!', :more => 'Click for more!').should == "<div class=\"dashboard empty\">\n  <div class=\"feedback\">\n    <div class=\"status\"></div>\n    <input type=\"text\" autocorrect=\"off\" class=\"query\"/>\n    <div class=\"reset\" title=\"clear\"></div>\n  </div>\n  <input type=\"button\" class=\"search_button\" value=\"search\">\n</div>\n"
    end
  end
  
  describe "interface" do
    it "should return good html" do
      Picky::Helper.interface.should == "<div id=\"picky\">\n  <div class=\"dashboard empty\">\n  <div class=\"feedback\">\n    <div class=\"status\"></div>\n    <input type=\"text\" autocorrect=\"off\" class=\"query\"/>\n    <div class=\"reset\" title=\"clear\"></div>\n  </div>\n  <input type=\"button\" class=\"search_button\" value=\"search\">\n</div>\n\n  <div class=\"results\"></div>\n<div class=\"no_results\">Sorry, no results found!</div>\n<div class=\"allocations\">\n  <ol class=\"shown\"></ol>\n  <ol class=\"more\">more</ol>\n  <ol class=\"hidden\"></ol>\n</div>\n\n</div>\n"
    end
    it "should return good html" do
      Picky::Helper.interface(:button => 'find', :no_results => 'SORRY!', :more => 'Click for more!').should == "<div id=\"picky\">\n  <div class=\"dashboard empty\">\n  <div class=\"feedback\">\n    <div class=\"status\"></div>\n    <input type=\"text\" autocorrect=\"off\" class=\"query\"/>\n    <div class=\"reset\" title=\"clear\"></div>\n  </div>\n  <input type=\"button\" class=\"search_button\" value=\"find\">\n</div>\n\n  <div class=\"results\"></div>\n<div class=\"no_results\">SORRY!</div>\n<div class=\"allocations\">\n  <ol class=\"shown\"></ol>\n  <ol class=\"more\">Click for more!</ol>\n  <ol class=\"hidden\"></ol>\n</div>\n\n</div>\n"
    end
  end
  
end