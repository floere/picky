var PickyAllocationsCloud = function(view) {
  
  var allocations         = $('#picky .allocations');
  var shownAllocations    = allocations.find('.shown');
  var showMoreAllocations = allocations.find('.more');
  var hiddenAllocations   = allocations.find('.hidden');
  
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
  
  // TODO Move to allocation renderer?
  //
  var renderListItem = function(allocationRenderer) {
     var item = allocationRenderer.listItem();
     item.bind('click', { query: allocationRenderer.query, type: allocationRenderer.type }, function(event) {
       hide(); // TODO Move to callback.
       view.allocationChosen(event); // TODO Move to callback.
     });
     return item;
  };
  
  var createAllocationList = function(allocations) {
    var shown = [];
    allocations.each(function(i, allocation) {
      // shown.push(allocationRenderer.render(allocation));
      
      var allocationRenderer = new AllocationRenderer(allocation);
      
      // TODO Combine.
      allocationRenderer.generate();
      var listItem = renderListItem(allocationRenderer);
      
      shown.push(listItem);
    });
    return shown;
  };
  
  var renderList = function(list) {
    if (list.length == 0) {
      return $('#search .allocations').hide();
    }
    var maxSuggestions = 3;
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
    return $('#search .allocations').show();
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