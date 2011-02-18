var PickyResultsRenderer = function(addination) {
  
  // Adds asterisks to the last token.
  //
  var no_asterisks = ['street_number', 'zipcode']; // TODO Works. Parametrize!
  var asteriskifyLastToken = function(combination) {
    var last_part = combination[combination.length-1];
    var parts = combination.slice(0, combination.length-1);
    if (parts == []) { parts = [parts]; }
    if (!no_asterisks.include(last_part[0])) {
      // Replace with * unless there is already one or a tilde.
      //
      if (last_part[1].match(/[^\*~]$/)) { last_part[1] += '*'; }
    }
    parts.push(last_part);
    return parts;
  };
  
  // Replaces the category with an explanation of the category.
  //
  var explainCategory = function(combination) {
    var explanations = Localization.explanations && Localization.explanations[PickyI18n.locale] || {}; // TODO
    var parts = [];
    var combo;
    
    for (var i = 0, l = combination.length; i < l; i++) {
      combo = combination[i];
      var explanation = combo[0];
      explanation = explanations[explanation] || explanation;
      parts.push([explanation, combo[1]]);
    }
    return parts;
  };
  
  // Puts together an explanation.
  //
  // Note: Accumulates same categories using a whitespace.
  //
  var strongify = function(category, joinedTokens) {
    return [category.replace(/([\w\sÄäÖöÜüéèà]+)/, "<strong>$1</strong>"), joinedTokens].join(' ');
  };
  var explain = function(type, combination) {
    var explanation_delimiter = Localization.explanation_delimiters[PickyI18n.locale];
    
    var parts = explainCategory(asteriskifyLastToken(combination));
    var lastCategory     = '';
    var tokenAccumulator = [];
    var joinedTokens     = '';
    var replaced = $.map(parts, function(part) {
      var category = part[0];
      var token    = part[1];
      
      if (lastCategory == '' || category == lastCategory) {
        tokenAccumulator.push(token);
        lastCategory = category;
        
        return undefined;
      }
      
      var result = strongify(lastCategory, tokenAccumulator.join(' '));
      
      tokenAccumulator = [];
      tokenAccumulator.push(token);
      lastCategory = category;
      
      return result;
    });
    // there might be something in the accumulator
    //
    replaced.push(strongify(lastCategory, tokenAccumulator.join(' ')));
    
    replaced = replaced.join(' ' + explanation_delimiter + ' ');
    
    return '<span class="explanation">' + type + ' ' + replaced + '</span>';
  };
  
  // TODO Make customizable.
  //
  var renderHeader = function(data, allocation) {
    // TODO Make type definable. (Mapping, i18n)
    //
    var header_html = '<div class="header">';
    header_html += explain(allocation.type, allocation.combination);
    if (data.offset > 0) {
      header_html += '<div class="tothetop"><a href="#" onclick="javascript:$(\'body\').animate({scrollTop: 0}, 500);">&uarr;</a></div>'; // searchEngine.focus();
    }
    
    // TODO Parametrize!
    // var names = '';
    // var firstEntryName = $(allocation.entries[0]).find('.name').html();
    // var lastEntryName = $(allocation.entries[allocation.entries.length-1]).find('.name').html();
    // if(firstEntryName == lastEntryName) {
    //   var firstEntryFirstName = $(allocation.entries[0]).find('.first_name').html();
    //   var lastEntryFirstName = $(allocation.entries[allocation.entries.length-1]).find('.first_name').html();
    //   names = '<div class="names">' + firstEntryName + ', ' + firstEntryFirstName + ' ' + t('common.to') + ' ' + lastEntryFirstName + '</div>';
    // }
    // else {
    //   names = '<div class="names">' + firstEntryName + ' ' + t('common.to') + ' ' + lastEntryName + '</div>';
    // }
    
    // var rangeStart = data.offset + 1;
    // var rangeEnd = data.offset + allocation.entries.length;
    // var rangeText = (rangeStart == rangeEnd) ? rangeStart : rangeStart + '-' + rangeEnd;
    // var range = '<div class="range">' + rangeText + ' ' + t('common.of') + ' ' + data.total + '</div>';
    
    // if (data.total > 20) { // TODO Make settable.
    //   // header_html += '<div class="clear"></div>'; // TODO
    //   // header_html += names; // TODO
    //   // header_html += range; // TODO
    // }
    
    // // For smooth addination scrolling. Don't ask.
    //
    // header_html += '<div class="clear"></div></div>';
    
    return header_html;
  };
  
  // Render results with the data.
  //
  this.render = function(data) {
    var results = $('#picky div.results'); // TODO Extract, also from view.
    data.allocations.each(function(i, allocation) {
      results.append(renderHeader(data, allocation)) // TODO header.render(data);
             .append('<ol class="results">' + allocation.entries.join('') + '</ol>')
             .append(addination.render(data));
    });
  };
};