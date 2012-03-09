module Picky

  # This class provides a few view helpers.
  #
  class Helper
    
    @@localized_input    = lambda { |options|
      search_button_text = options[:button]     || 'search'
<<-HTML
<form class="empty" onkeypress="return event.keyCode != 13;">
  <!-- <div class="feedback"> -->
    <div class="status"></div>
    <input type="search" autocorrect="off" class="query"/>
    <a class="reset" title="clear"></a>
  <!-- </div> -->
  <input type="button" value="#{search_button_text}"/>
</form>
HTML
    }
    @@localized_results = lambda { |options|
      no_results        = options[:no_results] || 'Sorry, no results found!'
      more_allocations  = options[:more]       || 'more'
<<-HTML
<div class="results"></div>
<div class="no_results">#{no_results}</div>
<div class="allocations">
  <ol class="shown"></ol>
  <ol class="more">#{more_allocations}</ol>
  <ol class="hidden"></ol>
</div>
HTML
    }
    @@localized_interface = lambda { |options|
<<-HTML
<section class="picky">
  #{@@localized_input[options]}
  #{@@localized_results[options]}
</section>
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
      @@localized_interface[options]
    end
    def self.input options = {}
      @@localized_input[options]
    end
    def self.results options = {}
      @@localized_results[options]
    end
    
    # Returns a cached version if you always use a single language.
    #
    def self.cached_interface options = {}
      @interface ||= interface(options).freeze
    end
    
  end
  
end