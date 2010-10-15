var PickyAllocationsCloudRenderer = function(view, data) {
  var self = this;

  this.view        = view; // TODO Should it not have the VIEW? Would make much more sense.
  this.allocations = data.allocations;
  this.shown       = [];

  this.render = function() {
    this.createAllocationList();
    this.renderList(this.shown);
  };

  this.createAllocationList = function() {
    this.allocations.each(function(i, allocation) {
      var allocationRenderer = new AllocationRenderer(allocation);
      allocationRenderer.generate();
      
      var listItem = self.renderListItem(allocationRenderer);
      self.shown.push(listItem);
    });
  };

  // TODO Move to allocation renderer?
  //
  this.renderListItem = function(allocationRenderer) {
     var item = allocationRenderer.listItem();
     item.bind('click', { query: allocationRenderer.query, type: allocationRenderer.type }, this.view.allocationsCloudClickEventHandler);
     return item;
  };
  
  this.renderList = function(list) {
    if (list.length == 0) {
      return $('#search .allocations').hide();
    }
    var maxSuggestions = 3;
    self.view.clearAllocationCloud();
    
    if (list.length > maxSuggestions) {
      $.each(list.slice(0,maxSuggestions-1), function(i, item) {
        self.view.appendShownAllocation(item);
      });
      $.each(list.slice(maxSuggestions-1), function(i, item) {
        self.view.appendHiddenAllocation(item);
      });
      view.showMoreAllocations();
    }
    else {
      $.each(list, function(i, item) {
        self.view.appendShownAllocation(item);
      });
    }
    return $('#search .allocations').show();
  };

};