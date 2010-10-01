module Picky

  # This class provides a few view helpers.
  #
  class Helper
    
    # TODO I18n stuff!
    #
    @@interface_html = <<-HTML
<div id="picky">
  <div class="dashboard empty">
    <div class="feedback">
      <div title="# results" class="status"></div>
      <input type="text" class="query" autocorrect="off">
      <div title="clear" class="reset"></div>
    </div>
    <input type="button" value="search" class="search_button">
  </div>
</div>
    HTML
    @@interface_html.gsub!(/[\n]/, '').squeeze!(' ')
    @@interface_html.freeze
    #
    # Returns
    #
    def self.interface
      @@interface_html
    end
    
  end

end