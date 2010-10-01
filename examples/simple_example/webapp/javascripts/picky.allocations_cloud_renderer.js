var PickyAllocationsCloudRenderer = function(controller, data) {
  var self = this;

  this.controller  = controller;
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
     var item = $('<li><div class="text">' + allocationRenderer.text + '</div><div class="count">' + allocationRenderer.count + '</div></li>');
     item.bind('click', { query: allocationRenderer.query, type: allocationRenderer.type }, this.controller.allocationsCloudClickEventHandler);
     return item;
  };
  
  this.renderList = function(list) {
    if (list.length == 0) {
      $('#search .allocations').hide();
      return;
    }
    var maxSuggestions = 3;
    var shown = $('#search .allocations .shown').empty();
    var more  = $('#search .allocations .more').hide();
    var hidden = $('#search .allocations .hidden').empty().hide();

    if (list.length > maxSuggestions) {
      $.each(list.slice(0,maxSuggestions-1), function(i, item) {
        shown.append(item);
      });
      $.each(list.slice(maxSuggestions-1), function(i, item) {
        hidden.append(item);
      });
      more.show();
    }
    else {
      $.each(list, function(i, item) {
        shown.append(item);
      });
    }
    $('#search .allocations').show();
  };

};