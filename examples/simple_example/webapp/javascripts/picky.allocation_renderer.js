var Localization = {
  // This is used to generate the correct query strings, localized.
  //
  // e.g with locale it:
  // ['name'], ['Hanke'] => 'nome:Hanke'
  //
  // This needs to correspond to the parsing in the search engine.
  //
  qualifiers: {},
  // This is used to explain the preceding word in the suggestion text.
  //
  // e.g. with locale it:
  // ['name'], ['hanke'] => 'name (cognome)'
  //
  explanations: {},
  // Located in the suggestion text between what and where.
  //
  // e.g. french:
  // ['name', 'city'], ['Hanke', 'Zürich'] => 'Hanke (nom) à Zürich'
  //
  // TODO Remove.
  //
  location_delimiters: { de:'in', fr:'à', it:'a', en:'in', ch:'in' },
  explanation_delimiters: { de:'und', fr:'et', it:'e', en:'and', ch:'und' }
};

function AllocationRenderer(allocation) {
  var self = this;

  var locale                = PickyI18n.locale;
  
  var qualifiers            = Localization.qualifiers && Localization.qualifiers[locale] || {};
  var explanations          = Localization.explanations && Localization.explanations[locale] || {};
  var location_delimiter    = Localization.location_delimiters[locale];
  var explanation_delimiter = Localization.explanation_delimiters[locale];
  
  var combination = allocation.combination;
  var type        = allocation.type;
  var count       = allocation.count;
  
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
  
  // TODO Parametrize!
  var specialWhoCases = {
    "maiden_name" : { format:"(-%1$s)", method:'capitalize', ignoreSingle:true },
    "name"        : { format:"<strong>%1$s</strong>", method:'toUpperCase', ignoreSingle:true },
    "first_name"  : { format:"%1$s", method:"capitalize" }
  };
  function handleWho(both, singleParam) {
    var single = singleParam || false;
    var allocation = both[0];
    var word       = both[1];

    var formatting = specialWhoCases[allocation];
    if (formatting) {
      if (formatting.method) { word = word[formatting.method](); }
      if (formatting.format) { word = formatting.format.replace(/%1\$s/, word); }
    }
    var explanation = explanations[allocation] || allocation;
    if (single && !(formatting && formatting.ignoreSingle)) { return word + '&nbsp;(' + explanation + ')'; }

    return word;
  }
  // Handles the first (who) part.
  //
  // Rules:
  //  * If there is no thing, do return an empty string.
  //  * If there is only one thing, add an explanation.
  //  * If there are multiple things, handle special cases.
  //    Without special cases, the name is always in front.
  //    The things are separated by commas, and explained.
  //    If there are multiple instances of the same category, they are contracted.
  //
  //  Note: &nbsp; to not disconnect the explanation from the query text.
  //
  function who(zipped) {
    if (zipped.length == 0) {
      return '';
    } else if (zipped.length == 1) {
      return handleWho(zipped[0], true);
    } else {
      // else, sort, special cases etc.
      var result = [];
      var append = [];
      zipped = contract(zipped);
      for (var i = 0, l = zipped.length; i < l; i++) {
        if (zipped[i][0] == 'first_name') {
          result.unshift(handleWho(zipped[i])); // prepend the first name
        } else {
          if (zipped[i][0] == 'maiden_name') {
            append.push(handleWho(zipped[i]));
          } else {
            result.push(handleWho(zipped[i]));
          }
        }
      };
      if (append.length > 0) { result.push(append); };
      return result.join(' ');
    }
  }
  this.who = who;

  function replacerFor(zipped) {
    return function(_, category) {
      for (var i = 0, l = zipped.length; i < l; i++) {
        if (zipped[i][0] == category) { return zipped[i][1]; };
      };
      return '';
    };
  };

  // Handles the second (where) part.
  //
  // Rules:
  //  * If there is no location, do return an empty string.
  //  * If there is only a zipcode, add a [<city explanation>].
  //  * If there is only a city, add nothing.
  //  * If there are both, zipcode needs to be first.
  //  TODO Contraction of multiple "cities" and/or zipcode.
  //
  var locations = {
    'zipcode':(':zipcode [' + explanations.city + ']'),
    'city':':city',
    'city,zipcode':':zipcode :city'
  };
  function where(zipped) {
    if (zipped.length == 0) { return ''; };
    zipped = contract(zipped);
    var key_ary = zipped;
    key_ary.sort(function(zipped1, zipped2) {
      return zipped1[0] < zipped2[0] ? -1 : 1;
    });
    // Now that it's sorted, get the right string.
    var key = [];
    for (var i = 0, l = key_ary.length; i < l; i++) {
      key.push(key_ary[i][0]);
    };
    var loc = locations[key];
    // Replace inside string.
    var result = loc.replace(/:(zipcode|city)/g, replacerFor(zipped));
    return result;
  };
  this.where = where;

  function handleSingleWhat(both) {
    var allocation = both[0];
    var word       = both[1];
    
    var explanation = explanations[allocation] || allocation;
    
    return word + '&nbsp;(' + explanation + ')';
  }
  function what(zipped) {
    if (zipped.length == 0) { return ''; };

    result = [];
    zipped = contract(zipped);
    for (var i = 0, l = zipped.length; i < l; i++) {
      result.push(handleSingleWhat(zipped[i]));
    }

    return result.join(', ');
  };
  this.what = what;

  // Orders the allocation identifiers according to
  // [<who>, <what>, <where>]
  // Returns a reordered array.
  //
  var who_qualifiers = ['first_name', 'name', 'maiden_name'];
  var where_qualifiers = ['zipcode', 'city'];
  function trisect(zipped) {
    var who_parts = [];
    var what_parts = [];
    var where_parts = [];

    for (var i = 0, l = zipped.length; i < l; i++) {
      var combination = zipped[i];
      if (where_qualifiers.include(combination[0])) {
        where_parts.push(combination);
      } else if (who_qualifiers.include(combination[0])) {
        who_parts.push(combination);
      } else {
        what_parts.push(combination);
      }
    }

    // Ellipsisize the last part
    var alloc_part;
    if (where_parts.length > 0) {
      alloc_part = where_parts[where_parts.length-1];
    } else if (what_parts.length > 0) {
      alloc_part = what_parts[what_parts.length-1];
    } else if (who_parts.length > 0) {
      alloc_part = who_parts[who_parts.length-1];
    } // always results in a part
    if (!no_ellipses.include(alloc_part[0])) { alloc_part[1] += '...'; } // TODO *

    var rendered_who   = who(who_parts);
    var rendered_what  = what(what_parts);
    var rendered_where = where(where_parts);
    return [rendered_who, rendered_what, rendered_where];
  };
  this.trisect = trisect;

  // Fuses a possible who part to a possible what part to a possible where part.
  //
  // e.g. <who>, <what> in <where>
  //
  // Note: &nbsp; to not disconnect the location delimiter (e.g. "in") from the location.
  //
  // TODO Parametrize!
  //
  var who_what_join      = ', ';
  var whowhat_where_join = ' ' + location_delimiter + '&nbsp;';
  function fuse(parts) {
    var who = parts[0], what = parts[1], where = parts[2];
    var who_what = '';
    if (who != '') {
      if (what != '') { who_what = [who, what].join(who_what_join); } else { who_what = who; }
    } else {
      who_what = what;
    }
    if (where == '') { return who_what; };
    return [who_what, where].join(whowhat_where_join);
  };
  this.fuse = fuse;

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
    return fuse(trisect(zipped));
  };


  // Generates the text and the link.
  //
  this.generate = function() {
    this.query       = querify(combination);
    this.text        = suggestify(combination);
    
    return self;
  };
  
  //
  //
  this.listItem = function() {
    return $('<li><div class="text">' + this.text + '</div><div class="count">' + count + '</div></li>');
  };

};