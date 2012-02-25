var PickyAllocationsCloud = function(view, config) {
  
  var allocations         = config['allocations'];
  var shownAllocations    = config['shownAllocations'];
  var showMoreAllocations = config['showMoreAllocations'];
  var hiddenAllocations   = config['hiddenAllocations'];
  var maxSuggestions      = config['maxSuggestions'];
  
  // Show the cloud.
  //
  var show = function(data) {
    render(data.allocations);
    allocations.show();
  };
  // Hide the cloud.
  //
  var hide = function() {
    allocations.hide();
  };
  
  var clearAllocationCloud = function() {
    shownAllocations.empty();
    showMoreAllocations.hide();
    hiddenAllocations.empty().hide();
  };
  
  // 
  //
  var allocationChosenCallback = function(event) {
    hide();
    view.allocationChosen(event);
  };
  
  var allocationRenderer = new AllocationRenderer(config);
  
  // How an allocation renders as a list item.
  //
  var listItem = function(text, count) {
    return $('<li><div class="text">' + text + '</div><div class="count">' + count + '</div></li>');
  };
  
  //
  //
  var createAllocationList = function(allocations) {
    var shown = [];
    
    allocations.each(function(i, allocation) {
	    var rendered = allocationRenderer.render(allocation);
      var query    = allocationRenderer.querify(allocation.combination);
      
      rendered = listItem(rendered, allocation.count);
      rendered.bind('click', { query: query }, allocationChosenCallback);
	    
      shown.push(rendered);
    });
    
    return shown;
  };
  
  var renderList = function(list) {
    if (list.length == 0) {
      return allocations.hide();
    }
    clearAllocationCloud();
    
    if (list.length > maxSuggestions) {
      $.each(list.slice(0,maxSuggestions-1), function(i, item) {
        shownAllocations.append(item);
      });
      $.each(list.slice(maxSuggestions-1), function(i, item) {
        hiddenAllocations.append(item);
      });
      showMoreAllocations.show();
    }
    else {
      $.each(list, function(i, item) {
        shownAllocations.append(item);
      });
    }
    return allocations.show();
  };
  
  // Render the allocation list.
  //
  var render = function(allocations) {
    renderList(createAllocationList(allocations));
  };
  
  // Install handlers.
  //
  showMoreAllocations.click(function() {
    showMoreAllocations.hide();
    hiddenAllocations.show();
  });
  
  // Expose hide and show.
  //
  this.hide = hide;
  this.show = show;
  
};