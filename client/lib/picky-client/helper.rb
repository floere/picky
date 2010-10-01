module Picky

  # This class provides a few view helpers.
  #
  class Helper
    
    @@interface_html = <<-HTML
<div class="picky_dashboard empty">
  <div class="picky_feedback">
    <div title="# results" class="picky_status"></div>
    <input type="text" class="picky_query" autocorrect="off">
    <div title="clear" class="picky_reset"></div>
  </div>
  <input type="button" value="search" class="picky_search_button" style="margin-top: 3px;">
</div>
    HTML
    @@interface_html.gsub!(/[\n]/, '').squeeze!(' ')
    @@interface_html.freeze
    #
    # 
    #
    def self.interface
      @@interface_html
    end
    
  end

end