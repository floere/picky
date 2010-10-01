// Translations
//
var PickyI18n = { locale:'en' };

// Set the correct locale for all js code.
//
$(function() {
  PickyI18n.locale = $('html').attr('lang');
});

var dictionary = {
  common:{
    company:{de:'Firma',fr:'Entreprise',it:'Azienda',en:'company',ch:'Firma'},
    person: {de:'Privat',fr:'Personnes',it:'Privato',en:'person',ch:'Person'},
    join:   {de:'und',fr:'et',it:'e',en:'and',ch:'und'},
    'with': {de:'mit',fr:'avec',it:'con',en:'with',ch:'mit'},
    of: {de:'von',fr:'de',it:'di',en:'of',ch:'vo'},
    to: {de:'bis',fr:'à',it:'alla',en:'to',ch:'bis'},
    filename:{de:'Dateiname', fr:'Nom de fichier', it: 'Nome file', en: 'Filename', ch: 'Dateinamä'},
    filesize:{de:'Dateigrösse', fr: 'Dimension du fichier', it: 'Dimensione file', en: 'Filesize', ch: 'Dateigrössi'}
  },
  suggestions:{
    top:{
      header:{
        de: 'Top-Einträge',
        fr: 'Inscriptions Top',
        it: 'Contatti Top',
        en: 'Top Entries',
        ch: 'Topiiträg'
      }
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
      info: {
        type: {
          company: {
            de: 'Firmen mit',
            fr: 'Entreprises avec',
            it: 'Aziende con',
            en: 'Companies with',
            ch: 'Firmä mit'
          },
          person: {
            de: 'Personen mit',
            fr: 'Particuliers avec',
            it: 'Privati con',
            en: 'Persons with',
            ch: 'Personä mit'
          }
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
  },
  SWFUpload:{
    info:{
      noImage: {
        de: 'Kein Bild gespeichert',
        fr: 'Pas de photo sauvegardée',
        it: 'Nessuna immagine salvata',
        en: 'No image saved',
        ch: 'Käs Bild gschpeicherät'
      }
    },
    progress: {
      uploading: {
        de: 'Uploading...',
        fr: 'Téléchargement en cours...',
        it: 'Caricamento in corso...',
        en: 'Uploading...',
        ch: 'Ufeladä...'
      },
      processing: {
        de: 'Bild wird verarbeitet.',
        fr: "L'image est traitée.",
        it: 'Elaborazione immagine in corso.',
        en: 'Image is being converted.',
        ch: 'S Bild wird verarbeität.'
      },
      finished: {
        de: 'Fertig. Dateiname: ',
        fr: 'Terminé. Nom du fichier :',
        it: 'Fine. Nome file:',
        en: 'Finished. Filename:',
        ch: 'Fertig. Dateinamä:'
      }
    },
    imageAdvertisement: {
      progress: {
        finished: {
          de: 'Fertig. Dateiname: ',
          fr: 'Terminé. Nom du fichier :',
          it: 'Fine. Nome file:',
          en: 'Finished. Filename:',
          ch: 'Fertig. Dateinamä:'
        }
      }
    },
    QUEUE_ERROR:{
      ZERO_BYTE_FILE:{
        de: 'Die Datei ist leer',
        fr: 'Le fichier est vide.',
        it: 'Il file è vuoto.',
        en: 'File is empty.',
        ch: 'D Datei isch läär.'
      },
      FILE_EXCEEDS_SIZE_LIMIT:{
        de: 'Die Datei ist zu gross. Erlaubt sind max. 10MB.',
        fr: 'Le fichier est trop volumineux. Le maximum autorisé est de 10 Mo.',
        it: 'Il file è troppo grande. Sono consentiti max 10MB.',
        en: 'The file is too large. We accept max. 10MB.',
        ch: 'D Datei isch z\'gross. Erlaubt sind max. 10MB.'
      },
      INVALID_FILETYPE:{
        de: 'Sie können nur jpg, png und gif laden',
        fr: 'Les seules images que vous pouvez télécharger sont du type JPG, PNG ou GIF.',
        it: 'È possibile caricare solo immagini in formato jpg, png o gif.',
        en: 'We accept only jpg, png and gif filetypes',
        ch: 'Si chönd nur jpg, png und gif ladä'
      }
    },
    error:{
      _default:{
        de:'Fehler beim Upload',
        fr:'Erreur au téléchargement',
        it: 'Errore durante il caricamento',
        en: 'Error during upload',
        ch: 'Fehlär bim Ufäladä'
      },
      flash:{
        de:'Für den Bildupload benötigen Sie den <a href="http://get.adobe.com/de/flashplayer/">Flash-Player</a>',
        fr:"Pour le téléchargement d'images, il vous faut le <a href='http://get.adobe.com/de/flashplayer/'>Flash-Player</a>",
        it: "Per il caricamento dell'immagine è necessario <a href=\"http://get.adobe.com/de/flashplayer/\">Flash-Player</a>",
        en: 'For the image upload you need the <a href="http://get.adobe.com/de/flashplayer/">flash player</a>',
        ch: 'Für dä Bildupload bruuchäd Si dä <a href="http://get.adobe.com/de/flashplayer/">Flashpläyer</a>'
      }
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