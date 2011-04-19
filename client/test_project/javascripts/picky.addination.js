var PickyAddination = function(view, results) {
  
  // Calculate the addination range.
  // 
  var calculateRange = function(data) {
    var numberOfResults = 20; // Make parametrizable.
    var offset  = data.offset + numberOfResults;
    var end     = offset + numberOfResults;
    var total   = data.total;
    if (total < end) { end = total; }
    return { offset:offset, start:(offset+1), end:end };
  };
  
  // Remove the addination.
  //
  var remove = function() {
    results.find('.addination').remove();
  };
  this.remove = remove;
  
  // Renders the addination;
  //
  var render = function(data) {
    var total = data.total;
    var range = calculateRange(data);
    if (range.offset < total) {
      var result = $("<div class='addination'>" + t('results.addination.more') + "</div>");
      result.bind('click', { offset: range.offset }, view.addinationClicked);
      return result;
    } else {
      return '';
    }
  };
  this.render = render;
  
};