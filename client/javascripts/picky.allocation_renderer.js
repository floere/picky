function AllocationRenderer(allocationChosenCallback, config) {
  var self = this;

  var locale                = PickyI18n.locale;
  
  var qualifiers            = Localization.qualifiers && Localization.qualifiers[locale] || {};
  var explanations          = Localization.explanations && Localization.explanations[locale] || {};
  var explanation_delimiter = Localization.explanation_delimiters[locale];
  
  var choiceGroups          = config.groups || [];
  var choices               = Localization.choices && Localization.choices[locale] || {};
  
  // Those are of interest to the public.
  //
  this.text = '';
  this.query = '';
  this.explanation = '';
  
  // TODO parametrize.
  //
  var no_ellipses           = ['street_number', 'zipcode'];
  
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
  function makeUpMissingFormat(key) {
    return $.map(key, function(element, i) {
      return '%' + (i+1) + '$s';
    }).join(' ');
  };
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
    var key = [];
    for (var i = 0, l = key_ary.length; i < l; i++) {
      key.push(key_ary[i][0]);
    };
    
    // Get the right formatting or make up a simple one.
    //
    // var result = choices[key] || (choices[key] = makeUpMissingFormat(key));
    
    var single = key.length == 1;
    
    // Get the formatting to be replaced.
    //
    var formatting = choices[key] || (choices[key] = makeUpMissingFormat(key));
    // If someone uses the simple format, change into complex format.
    //
    if ($.type(formatting) === "string") {
      choices[key] = { format: formatting };
      formatting = choices[key];
    };
    
    var j = 1;
    var result = formatting.format;
    
    // Replace each word into the formatting string.
    //
    $.each(zipped, function(i, author_original_token) {
      var category = author_original_token[0];
      var word     = author_original_token[1];
      
      if (formatting.filter) { word = formatting.filter(word); }
      
      var explanation = explanations[category] || category;
      if (single && !(formatting && formatting.ignoreSingle)) {
        result = word + '&nbsp;(' + explanation + ')';
        return result;
      }
      
      var regexp = new RegExp("%" + j + "\\$s", "g");
      result = result.replace(regexp, word);
      
      j += 1;
      
      return j;
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
    if (!no_ellipses.include(last_part[0])) { last_part[1] += '...'; } // TODO *
    
    // Render each group and return the resulting rendered array.
    //
    return $.map(groups, function(group) {
      return rendered(group);
    });
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
      query_parts[i] = qualifier + ':' + zipped[i][1];
    };
    return query_parts.join(' ');
  };
  this.querify = querify;

  //
  //
  function suggestify(zipped) {
    return groupify(zipped).join(' ');
  };


  // Generates the text and the link.
  //
  var generate = function() {
    this.query       = querify(combination);
    this.text        = suggestify(combination);
    
    return self;
  };
  
  //
  //
  var listItem = function(text, count) {
    return $('<li><div class="text">' + text + '</div><div class="count">' + count + '</div></li>');
  };
  
  var render = function(allocation) {
    
    var combination = allocation.combination;
    var type        = allocation.type;
    var count       = allocation.count;
    
    var query       = querify(combination);
    
    var item = listItem(suggestify(combination), count);
    
    // TODO Move this outwards?
    //
    item.bind('click', { query: query }, allocationChosenCallback);
    return item;
  };
  this.render = render;

};