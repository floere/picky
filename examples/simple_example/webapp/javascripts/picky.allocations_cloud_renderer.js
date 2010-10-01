var PickyAllocationsCloudRenderer = function(controller, data) {
  var self = this;

  this.controller  = controller;
  this.allocations = data.allocations;
  this.companies   = [];
  this.people      = [];

  this.render = function() {
    this.createAllocationLists();
    this.renderLists();
  };

  this.createAllocationLists = function() {
    this.allocations.each(function(i, allocation) {
      var allocationRenderer = new AllocationRenderer(allocation);

      allocationRenderer.generate();
      var listItem = self.renderListItem(allocationRenderer);

      if (allocation.isType('c')) {
        self.companies.push(listItem);
      }
      else {
        self.people.push(listItem);
      }
    });
  };

  // TODO Move to allocation renderer?
  //
  this.renderListItem = function(allocationRenderer) {
     var item = $('<li><div class="text">' + allocationRenderer.text + '</div><div class="count">' + allocationRenderer.count + '</div></li>');
     item.bind('click', { query: allocationRenderer.query, type: allocationRenderer.type }, this.controller.allocationsCloudClickEventHandler);
     return item;
  };

  this.renderLists = function() {
    this.renderList('company', this.companies);
    this.renderList('person', this.people);
  };

  this.renderList = function(type, list) {
    if (list.length == 0) {
      $('#search .allocations .' + type).hide();
      return;
    }
    var maxSuggestions = 3;
    var shown = $('#search .allocations .' + type + ' .shown').empty();
    var more  = $('#search .allocations .' + type + ' .more').hide();
    var hidden = $('#search .allocations .' + type + ' .hidden').empty().hide();

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
    $('#search .allocations .' + type).show();
  };

};