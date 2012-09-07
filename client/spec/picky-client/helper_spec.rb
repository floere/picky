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
      Picky::Helper.input.should == "<form class=\"empty\" onkeypress=\"return event.keyCode != 13;\">\n    <div class=\"status\"></div>\n    <input type=\"search\" placeholder=\"Search here...\" autocorrect=\"off\" class=\"query\"/>\n    <a class=\"reset\" title=\"clear\"></a>\n  <input type=\"button\" value=\"search\"/>\n</form>\n"
    end
    it "should return good html" do
      Picky::Helper.input(:button => 'find').should == "<form class=\"empty\" onkeypress=\"return event.keyCode != 13;\">\n    <div class=\"status\"></div>\n    <input type=\"search\" placeholder=\"Search here...\" autocorrect=\"off\" class=\"query\"/>\n    <a class=\"reset\" title=\"clear\"></a>\n  <input type=\"button\" value=\"find\"/>\n</form>\n"
    end
  end
  
  describe "results" do
    it "should return good html" do
      Picky::Helper.input.should == "<form class=\"empty\" onkeypress=\"return event.keyCode != 13;\">\n    <div class=\"status\"></div>\n    <input type=\"search\" placeholder=\"Search here...\" autocorrect=\"off\" class=\"query\"/>\n    <a class=\"reset\" title=\"clear\"></a>\n  <input type=\"button\" value=\"search\"/>\n</form>\n"
    end
    it "should return good html" do
      Picky::Helper.input(:no_results => 'SORRY!', :more => 'Click for more!').should == "<form class=\"empty\" onkeypress=\"return event.keyCode != 13;\">\n    <div class=\"status\"></div>\n    <input type=\"search\" placeholder=\"Search here...\" autocorrect=\"off\" class=\"query\"/>\n    <a class=\"reset\" title=\"clear\"></a>\n  <input type=\"button\" value=\"search\"/>\n</form>\n"
    end
  end
  
  describe "interface" do
    it "should return good html" do
      Picky::Helper.interface.should == "<section class=\"picky\">\n  <form class=\"empty\" onkeypress=\"return event.keyCode != 13;\">\n    <div class=\"status\"></div>\n    <input type=\"search\" placeholder=\"Search here...\" autocorrect=\"off\" class=\"query\"/>\n    <a class=\"reset\" title=\"clear\"></a>\n  <input type=\"button\" value=\"search\"/>\n</form>\n\n  <div class=\"results\"></div>\n<div class=\"no_results\">Sorry, no results found!</div>\n<div class=\"allocations\">\n  <ol class=\"shown\"></ol>\n  <ol class=\"more\">more</ol>\n  <ol class=\"hidden\"></ol>\n</div>\n\n</section>\n"
    end
    it "should return good html" do
      Picky::Helper.interface(:button => 'find', :no_results => 'SORRY!', :more => 'Click for more!').should == "<section class=\"picky\">\n  <form class=\"empty\" onkeypress=\"return event.keyCode != 13;\">\n    <div class=\"status\"></div>\n    <input type=\"search\" placeholder=\"Search here...\" autocorrect=\"off\" class=\"query\"/>\n    <a class=\"reset\" title=\"clear\"></a>\n  <input type=\"button\" value=\"find\"/>\n</form>\n\n  <div class=\"results\"></div>\n<div class=\"no_results\">SORRY!</div>\n<div class=\"allocations\">\n  <ol class=\"shown\"></ol>\n  <ol class=\"more\">Click for more!</ol>\n  <ol class=\"hidden\"></ol>\n</div>\n\n</section>\n"
    end
  end
  
end