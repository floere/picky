// Translations
//
var PickyI18n = { };

// Set the correct locale for all js code.
//
$(function() {
  PickyI18n.locale = $('html').attr('lang') || 'en';
});

var dictionary = {
  common:{
    join:   {de:'und',fr:'et',it:'e',en:'and',ch:'und'},
    'with': {de:'mit',fr:'avec',it:'con',en:'with',ch:'mit'},
    of: {de:'von',fr:'de',it:'di',en:'of',ch:'vo'},
    to: {de:'bis',fr:'à',it:'alla',en:'to',ch:'bis'}
  },
  results:{
    addination:{
      more:{
        de: 'Weitere Resultate',
        fr: 'Autres résultats',
        it: 'Altri risultati',
        en: 'More results',
        ch: 'Mee Resultaat'
      }
    },
    header:{
      de: 'Ergebnisse',
      fr: 'Résultats',
      it: 'Risultati',
      en: 'Results',
      ch: 'Ergäbnis'
    }
  }
};
var t = function(key) {
  var locale = PickyI18n.locale || 'en';
  var keys = key.split('.').concat(locale);
  var current = dictionary;

  for (var i = 0, l = keys.length; i < l; i++) {
    current = current[keys[i]];
    if (current == undefined) {
      current = 'Translation missing: ' + key + '.' + locale;
      break;
    }
  };
  return current;
};