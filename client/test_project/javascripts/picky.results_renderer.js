var PickyResultsRenderer = function(addination, config) {
  
  var results = $(config['resultsSelector'] || '#picky div.results');
  var allocationWrapper = config['wrapResults'] || '<ol class="results"></ol>';
  
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
        // Remove categorization (including commas)
        // before the token.
        //
        token = token.replace(/[\w,]+:(.+)/, "$1");
        
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
    
    return header_html;
  };
  
  // Render results with the data.
  //
  this.render = function(data) {
    data.allocations.each(function(i, allocation) {
      // Only render if there is something to render.
      // TODO Move into methods.
      //
      if (allocation.entries.length > 0) {
        // TODO header.render(data);
        //
        results.append(renderHeader(data, allocation))
               .append(allocation.entries.join(''));
        results.children('li').wrapAll(allocationWrapper);
      }
    });
    results.append(addination.render(data));
  };
};