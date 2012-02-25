function AllocationRenderer(allocationChosenCallback, config) {
  var self = this;

  var locale = config.locale;
  
  // TODO Maybe make dynamic.
  //
  var qualifiers   = config.qualifiers && config.qualifiers[locale] || {};
  var explanations = config.explanations && config.explanations[locale] || {};
  var choiceGroups = config.groups || [];
  var choices      = config.choices && config.choices[locale] || {};
  var nonPartial   = config['nonPartial'] || [];
  
  // Those are of interest to the public.
  //
  this.text = '';
  this.query = '';
  this.explanation = '';
  
  // Contracts the originals of the zipped.
  //
  function contract(zipped) {
    var hash = {}; // remembers the values
    var insert = {}; // remembers the insertion locations
    var remove = []; // remembers the remove indexes
    var i;
	
    for (i = 0, l = zipped.length; i < l; i++) {
      var key = zipped[i][0];
      if (key in hash) {
        hash[key] = hash[key] + ' ' + zipped[i][1];
        remove.push(i);
      } else {
        hash[key] = zipped[i][1];
        insert[i] = key;
      }
    }
    // Insert the ones from the hash.
    for (i in insert) {
      zipped[i][1] = hash[insert[i]];
    }
    // Remove the ones from zipped we don't like. From the end.
    for (i = remove.length-1; i >= 0; i--) {
      zipped.remove(remove[i]);
    }
    
    return zipped;
  };
  this.contract = contract;

  // Renders the given combinations according to the
  // choice formatting defined in the config.
  //
  function makeUpMissingFormat(keys) {
	  var result = [];
	  keys.each(function(i, _) {
      result.push('%' + (i+1) + '$s');
    });
    return result.join(' ');
  };
  this.makeUpMissingFormat = makeUpMissingFormat;
  
  //
  //
  function rendered(zipped) {
    // Return an empty string if there are no combinations.
    //
    if (zipped.length == 0) { return ''; };
    
    zipped = contract(zipped);
    
    var key_ary = zipped;
    key_ary.sort(function(zipped1, zipped2) {
      return zipped1[0] < zipped2[0] ? -1 : 1;
    });
    
    // Now that it's sorted, get the right string.
    //
    var keys = [];
    for (var i = 0, l = key_ary.length; i < l; i++) {
      keys.push(key_ary[i][0]);
    };
    
    // Get the right formatting or make up a simple one.
    //
    // var result = choices[key] || (choices[key] = makeUpMissingFormat(key));
    
    var single = keys.length == 1;
    
    // Get the formatting to be replaced.
    //
    var formatting = choices[keys.join(',')] || (choices[keys] = makeUpMissingFormat(keys));
    // If someone uses the simple format, change into complex format.
    //
    if (typeof formatting === "string") {
      choices[keys] = { format: formatting };
      formatting = choices[keys];
    };
    
    var j = 1;
    var result = formatting.format;
    
    // Replace each word into the formatting string.
    //
    zipped.each(function(i, original_token) {
      var category = original_token[0];
      var word     = original_token[2];
	  
      if (formatting.filter) { word = formatting.filter(word); }
	  
      var explanation = explanations[category] || category;
      if (single && !(formatting && formatting.ignoreSingle)) {
        result = word + '&nbsp;(' + explanation + ')';
        return result;
      }
      
      var regexp = new RegExp("%" + (i+1) + "\\$s", "g");
      result = result.replace(regexp, word);
    });
    
    return result;
  };
  this.rendered = rendered;

  // Orders the allocation identifiers according to
  // a group definition array passed with the config.
  //
  // Returns rendered groups.
  //
  function groupify(zipped) {
    
    // Create a parts array the same size as the groups array.
    //
    var groups = new Array(0);
    for (var k = 0, l = choiceGroups.length; k < l; k++) {
      groups.push([]);
    };
    
    // Add a last group of undefined categories.
    //
    groups.push([]);
    
    // Split the zipped into the defined groups.
    //
    for (var i = 0, m = zipped.length; i < m; i++) {
      var combination = zipped[i];
      var category    = combination[0];
      
      var wasInGroups = false;
      
      for (var j = 0, n = choiceGroups.length; j < n; j++) {
        if (choiceGroups[j].include(category)) {
          groups[j].push(combination);
          wasInGroups = true;
          break;
        }
      };
      
      // The category hadn't been defined in a group.
      // Push it onto the last one.
      //
      if (!wasInGroups) {
        groups[groups.length-1].push(combination);
      }
      
    };
    
    // Append ellipses at the last group with something.
    //
    var last_part;
    for (var g = groups.length-1; g >= 0; g--) {
      last_part = groups[g];
      if (last_part.length > 0) { break; }
    };
    
    // Take the last part of each group
    //
    last_part = last_part[last_part.length-1];
    
    // And append ellipses.
    //
    if (!nonPartial.include(last_part[0])) { last_part[1] += '...'; }
    
    // Render each group and return the resulting rendered array.
    //
    var result = [];
    groups.each(function(i, group) {
      result.push(rendered(group));
    });
    
    return result;
  };
  this.groupify = groupify;

  // Creates a query string from combination and originals.
  //
  function querify(zipped) {
    var query_parts = [];
    var qualifier;
    
    for (var i in zipped) {
      qualifier = zipped[i][0];
      qualifier = qualifiers[qualifier] || qualifier; // Use the returned qualifier if none is given.
      query_parts[i] = qualifier + ':' + zipped[i][2];
    };
    
    return query_parts.join(' ');
  };
  this.querify = querify;

  //
  //
  function suggestify(zipped) {
    return groupify(zipped).join(' ');
  };
  this.suggestify = suggestify;
  
  var render = function(allocation) {
    return suggestify(allocation.combination);
  };
  this.render = render;

};