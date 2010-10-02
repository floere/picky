module Picky

  # This class provides a few view helpers.
  #
  class Helper
    
    @@localized_interface = lambda { |options|
      search_button_text = options[:button]     || 'search'
      no_results         = options[:no_results] || 'Sorry, no results found!'
      more_allocations   = options[:more]       || 'more'
<<-HTML
<div id="picky">
  <div class="dashboard empty">
    <div class="feedback">
      <div class="status"></div>
      <input type="text" autocorrect="off" class="query"/>
      <div class="reset" title="clear"></div>
    </div>
    <input type="button" class="search_button" value="#{search_button_text}">
  </div>
  <ol class="results"></ol>
  <div class="no_results">#{no_results}</div>
  <div class="allocations">
    <ol class="shown"></ol>
    <ol class="more">#{more_allocations}</ol>
    <ol class="hidden"></ol>
  </div>
</div>
HTML
    }
    
    # Returns a standard search interface for easy starting.
    #
    # ... aka scaffolding ;)
    #
    # Options:
    #  * button: The search button text.
    #  * no_results: The text shown when there are no results.
    #  * more: The text shown when there are more than X results.
    #
    # Usage, in Views:
    #
    #   = Picky::Helper.interface :button => 'Go go go!'
    #
    #
    def self.interface options = {}
      @@localized_interface[options].gsub!(/[\n]/, '').squeeze! ' '
    end
    
    # Returns a cached version if you always use a single language.
    #
    def self.cached_interface options = {}
      @interface ||= interface(options).freeze
    end
    
  end
  
end