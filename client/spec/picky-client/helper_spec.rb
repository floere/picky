require 'spec_helper'

describe Picky::Helper do
  
  describe "interface" do
    it "should return good html" do
      Picky::Helper.interface.should == '<div class="picky_dashboard empty"> <div class="picky_feedback"> <div title="# results" class="picky_status"></div> <input type="text" class="picky_query" autocorrect="off"> <div title="clear" class="picky_reset"></div> </div> <input type="button" value="search" class="picky_search_button" style="margin-top: 3px;"></div>'
    end
  end
  
end