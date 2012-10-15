module Picky

  # This class provides a few view helpers.
  #
  class Helper
    
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
<<-HTML
<section class="picky">
  #{input(options)}
  #{results(options)}
</section>
HTML
    end
    def self.input options = {}
<<-HTML
<form class="empty" onkeypress="return event.keyCode != 13;">
    <div class="status"></div>
    <input type="search" placeholder="#{options[:placeholder] || 'Search here...'}" autocorrect="off" class="query"/>
    <a class="reset" title="clear"></a>
  <input type="button" value="#{options[:button] || 'search'}"/>
</form>
HTML
    end
    def self.results options = {}
<<-HTML
<div class="results"></div>
<div class="no_results">#{options[:no_results] || 'Sorry, no results found!'}</div>
<div class="allocations">
  <ol class="shown"></ol>
  <ol class="more">#{options[:more] || 'more'}</ol>
  <ol class="hidden"></ol>
</div>
HTML
    end
    
    # Returns a cached version if you always use a single language.
    #
    def self.cached_interface options = {}
      @interface ||= interface(options).freeze
    end
    
  end
  
end