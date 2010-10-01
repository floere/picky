require 'spec_helper'

describe Picky::Helper do
  
  describe "interface" do
    it "should return good html" do
      Picky::Helper.interface.should == "<div id=\"picky\"> <div class=\"dashboard empty\"> <div class=\"feedback\"> <div title=\"# results\" class=\"status\"></div> <input type=\"text\" class=\"query\" autocorrect=\"off\"> <div title=\"clear\" class=\"reset\"></div> </div> <input type=\"button\" value=\"search\" class=\"search_button\"> </div></div>"
    end
  end
  
end