require 'spec_helper'

describe Picky::Helper do
  
  describe "cached_interface" do
    it "should return good html" do
      Picky::Helper.cached_interface.should == Picky::Helper.interface
    end
    it "should return the cached interface" do
      Picky::Helper.cached_interface.object_id.should == Picky::Helper.cached_interface.object_id
    end
    it "should be frozen" do
      Picky::Helper.cached_interface.should be_frozen
    end
  end
  
  describe "interface" do
    it "should return good html" do
      Picky::Helper.interface.should == "<div id=\"picky\"> <div class=\"dashboard empty\"> <div class=\"feedback\"> <div class=\"status\"></div> <input type=\"text\" autocorrect=\"off\" class=\"query\"/> <div class=\"reset\" title=\"clear\"></div> </div> <input type=\"button\" class=\"search_button\" value=\"search\"> </div> <ol class=\"results\"></ol> <div class=\"no_results\">Sorry, no results found!</div> <div class=\"allocations\"> <ol class=\"shown\"></ol> <ol class=\"more\">more</ol> <ol class=\"hidden\"></ol> </div></div>"
    end
    it "should return good html" do
      Picky::Helper.interface(:button => 'find', :no_results => 'SORRY!', :more => 'Click for more!').should == "<div id=\"picky\"> <div class=\"dashboard empty\"> <div class=\"feedback\"> <div class=\"status\"></div> <input type=\"text\" autocorrect=\"off\" class=\"query\"/> <div class=\"reset\" title=\"clear\"></div> </div> <input type=\"button\" class=\"search_button\" value=\"find\"> </div> <ol class=\"results\"></ol> <div class=\"no_results\">SORRY!</div> <div class=\"allocations\"> <ol class=\"shown\"></ol> <ol class=\"more\">Click for more!</ol> <ol class=\"hidden\"></ol> </div></div>"
    end
  end
  
end