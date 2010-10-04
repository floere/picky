var PickyResultsRenderer = function(controller, data) {

  var self = this;
  this.controller = controller;
  this.data = data;
  this.allocations = data.allocations;

  this.render = function() {
    this.allocations.each(function(i, allocation) {
      var header = self.renderHeader(allocation); // TODO Render header.
      var entries = self.renderEntries(allocation);
      var addination = self.renderAddination(self.data);
      $('#picky .results').append(header).append(entries).append(addination);
    });
  };
  
  // TODO Make customizable.
  //
  this.renderHeader = function(allocation) {
    var type = allocation.type; // Make definable.
    var explanation = '<div class="explanation">' + type + ' ' + this.explain(allocation.combination).replace(/([\wÄäÖöÜüéèà\/]+):([\wÄäÖöÜüéèà]+)/g, "<strong>$1</strong> $2") + '</div>';
    var rangeStart = this.data.offset + 1;
    var rangeEnd = this.data.offset + allocation.entries.length;
    var rangeText = (rangeStart == rangeEnd) ? rangeStart : rangeStart + '-' + rangeEnd;
    var range = '<div class="range">' + rangeText + ' ' + t('common.of') + ' ' + this.data.total + '</div>';
    var toTheTop = '<div class="tothetop"><a href="javascript:$.scrollTo(0,{ duration: 500 }); searchEngine.focus();">&uarr;</a></div>';

    var names = '';
    var firstEntryName = $(allocation.entries[0]).find('.name').html();
    var lastEntryName = $(allocation.entries[allocation.entries.length-1]).find('.name').html();

    if(firstEntryName == lastEntryName) {
      var firstEntryFirstName = $(allocation.entries[0]).find('.first_name').html();
      var lastEntryFirstName = $(allocation.entries[allocation.entries.length-1]).find('.first_name').html();
      names = '<div class="names">' + firstEntryName + ', ' + firstEntryFirstName + ' ' + t('common.to') + ' ' + lastEntryFirstName + '</div>';
    }
    else {
      names = '<div class="names">' + firstEntryName + ' ' + t('common.to') + ' ' + lastEntryName + '</div>';
    }

    var header_html = '<div class="info">';
    header_html += explanation;

    if (data.offset > 0) {
      header_html += toTheTop;
    }
    if (data.total > 20) {
      // header_html += '<div class="clear"></div>'; // TODO
      // header_html += names; // TODO
      // header_html += range; // TODO
    }
    header_html += '<div class="clear"></div></div>';
    
    return header_html;
  };
  
  this.renderEntries = function(allocation) {
    return allocation.entries.join('');
  };
  
  this.explain = function(combination) {
    var explanations          = Localization.explanations[PickyI18n.locale];
    var explanation_delimiter = Localization.explanation_delimiters[PickyI18n.locale];
    var no_ellipses           = ['street_number', 'zipcode']; // TODO Change!
    var parts = [];
    var combo;
    for (var i = 0, l = combination.length; i < l; i++) {
      combo = combination[i];
      parts.push([explanations[combo[0]], combo[1]].join(':'));
    }
    var last_part = parts[parts.length-1];
    parts = parts.slice(0, parts.length-1).join(', ');
    parts = parts ? [parts] : [];
    if (!no_ellipses.include(combo[0])) {
      last_part += '...';
    }
    parts.push(last_part);
    return parts.join(' ' + explanation_delimiter + ' ');
  };
  
  this.renderAddination = function(data) {
    var total = data.total;
    var range = this.calculateAddinationData();
    if (range.offset < total) {
      var addination = $("<div class='addination current'>" + t('results.addination.more') + "<div class='tothetop'><a href='javascript:$.scrollTo(0,{ duration: 500});'>&uarr;</a></div></div>");
      addination.bind('click', { offset: range.offset}, this.controller.addinationClickEventHandler);
      return addination;
    } else {
      return '';
    }
  };
  
  this.calculateAddinationData = function(correction) {
    var correction = correction || 0;
    var results = 20; // Make parametrizable.
    var offset  = data.offset + results + correction;
    var end     = offset + results;
    var total   = data.total;
    if (total < end) { end = total; }
    return { offset:offset, start:(offset+1), end:end };
  };
};