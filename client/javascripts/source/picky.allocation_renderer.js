"use strict";

function AllocationRenderer(config) {
  var self = this;

  var locale = config.locale;
  
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
  
  // Contracts the originals/parsed of the zipped into
  // an array of originals/parsed.
  //
  // Example:
  //     ['cat2', 'Orig1', 'parsed1'],
  //     ['cat1', 'Orig2', 'parsed2'],
  //     ['cat2', 'Orig3', 'parsed3']
  //   becomes
  //     ['cat2', ['Orig1', 'Orig3'], ['parsed1', 'parsed3']],
  //     ['cat1', ['Orig2'], ['parsed2']]
  //
  function contract(zipped) {
    var originals = {}; // Remembers the combined values.
    var parsed = {};
    var insert = {}; // Remembers the insertion locations.
    var remove = []; // Remembers the remove indexes.
    var i;
	  
    // Combine the values.
    //
		var l;
    for (i = 0, l = zipped.length; i < l; i++) {
      var key = zipped[i][0];
      if (key in originals) {
        originals[key].push(zipped[i][1]);
        parsed[key].push(zipped[i][2]);
        remove.push(i);
      } else {
        originals[key] = [zipped[i][1]];
        parsed[key]    = [zipped[i][2]];
        insert[i] = key;
      }
    }
    
    // Insert the combined values.
    //
    for (i in insert) {
      zipped[i][1] = originals[insert[i]];
      zipped[i][2] = parsed[insert[i]];
    }
    
    // Remove the ones from zipped we don't like. From the end.
    //
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
	  keys.map(function(i, _) {
      return '%' + (i+1) + '$s';
    });
    return keys.join(' ');
  };
  this.makeUpMissingFormat = makeUpMissingFormat;
  
  //
  //
  function rendered(allocation) {
    // Return an empty string if there are no combinations.
    //
    if (allocation.length == 0) { return ''; };
    
    var zipped = contract(allocation);
    
    var key_ary = zipped;
    // FIXME To remove or not to remove?
    //
    // key_ary.sort(function(zipped1, zipped2) {
    //   return zipped1[0] < zipped2[0] ? -1 : 1;
    // });
    
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
    var formatting = choices[keys.join(',')]
    if (formatting === undefined) { formatting = (choices[keys] = makeUpMissingFormat(keys)) };

    // If someone uses the simple format, change into complex format.
    //
    if (typeof formatting === "string") {
      choices[keys] = {
        format: formatting,
        ignoreSingle: true
      };
      formatting = choices[keys];
    };
    
    var j = 1;
    var result = formatting.format;
    
    // Replace each word into the formatting string.
    //
    zipped.each(function(i, original_token) {
      var category  = original_token[0];
      var originals = original_token[1];
      var words     = original_token[2];
	  
      // Add ellipses.
      //
      words.map(function(i, word) {
        var original = originals[i];
        if (original.charAt(original.length - 1) == "*") { word += "..."; }
        return word;
      });
    
      if (formatting.filter) {
        words.map(function(i, word) {
          return formatting.filter(word);
        });
      }
	  
      if (single && !(formatting && formatting.ignoreSingle)) {
        var explanation = explanations[category] || category;
        result = words.join('&nbsp;') + '&nbsp;(' + explanation + ')';
        return result;
      }
	    
      // Remove the category.
      //
      words.map(function(i, word) {
        return word.replace(/[\w,]+:(.+)/, "$1");
      });
      
      var regexp = new RegExp("%" + (i+1) + "\\$s", "g");
      result = result.replace(regexp, words.join('&nbsp;'));
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
    
    // And append "ellipses".
    //
    if (!nonPartial.include(last_part[0])) { last_part[1] = last_part[1].valueOf() + '*'; }
    
	  return groups;
  };
  this.groupify = groupify;

  // Creates a query string from combination and originals.
  //
  function querify(combination) {
    var query_parts = [];
    var qualifier;
    var original;
    
    for (var i in combination) {
      qualifier = combination[i][0];
      qualifier = qualifiers[qualifier] || qualifier; // Use the returned qualifier if none is given.
      original  = combination[i][1];
      original  = original || "";
      
      var partial = original.charAt(original.length - 1) == '*' ? '*' : ''; // TODO This is not the way to do this!
      query_parts[i] = qualifier + ':' + combination[i][2] + partial;
    };
    
    return query_parts.join(' ');
  };
  this.querify = querify;

  //
  //
  function suggestify(zipped) {
    var groups = groupify(zipped);
    
    // Render each group and return the resulting rendered array.
    //
    var result = [];
    groups.each(function(i, group) {
      var render = rendered(group);
      if (render) { result.push(render); }
    });
    
    return result.join(' ');
  };
  this.suggestify = suggestify;
  
  var render = function(allocation) {
    return suggestify(allocation.combination);
  };
  this.render = render;

};