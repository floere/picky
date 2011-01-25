var parameters = [
  'querying_removes_characters',
  'querying_stopwords',
  'querying_splits_text_on'
];

function hasBeenUpdated(name) {
  $('#parameters .' + name + ' input').css('background-color', 'lightgreen');
};

// If this returns true there were errors.
//
function handleErrors(data) {
  var error = false;
  $.each(data, function(index, element) {
    if (element == 'ERROR') {
      $('#parameters').find('.' + index + ' .error').html('Error in this config, not updated.');
      error = true;
    } else {
      $('#parameters').find('.' + index + ' .error').html('');
    }
  });
  return error;
};

// TODO Find a way to handle this correctly.
//
function rememberOriginal(name, data) {
  var input = $('#parameters .' + name + ' input');
  if (input.val() == '') {
    var originalValue = data[name];
    $('#parameters .' + name + ' span.original').html(', was&nbsp;&nbsp;' + originalValue + '&nbsp;&nbsp;on last reload.');
    $('#parameters .' + name + ' button.original').click(function() {
      input.val(originalValue);
      hasBeenUpdated(name);
    });
  };
};

function updateParameter(name, data) {
  var input = $('#parameters .' + name + ' input');
  input.val(data[name]);
  $('#parameters .' + name + ' input').css('background-color', 'white');
};

var firstTime = true;
var pickyPositiveAnswers = ['Yes', 'Ok', 'Fine', 'Done', 'Good', 'Alright', 'Sure', 'As you wish', 'Made adjustments'];
var pickyNegativeAnswers = ['Nu-uh', 'Nope', 'Sorry', 'No', 'Whoops', 'Oy vey', 'Oh dear', "That didn't work"];

function updateParameters(data) {
  if (handleErrors(data)) {
    $('#actions .status').html('Picky answered: ' + pickyNegativeAnswers[Math.round(Math.random()*(pickyNegativeAnswers.length-1))] + '.').fadeIn(200).fadeOut(800);
    return;
  } else {
    $('#actions .status').html('Picky answered: ' + pickyPositiveAnswers[Math.round(Math.random()*(pickyPositiveAnswers.length-1))] + '.').fadeIn(200).fadeOut(800);
  };
  $.each(parameters, function(index, parameter) {
    if (firstTime) { rememberOriginal(parameter, data); }
    updateParameter(parameter, data);
  });
  if (firstTime) { firstTime = false; };
};

function getParameters() {
  var data = {};
  
  $('#actions button').attr('disabled', 'disabled');
  
  $.each(parameters, function(index, parameter) {
    var value = $('#parameters .' + parameter + ' input').val();
    if (value != '') { data[parameter] = value; };
  });
  
  $.ajax({
    url: 'index.json',
    data: data,
    success: function(data) {
      data = $.parseJSON(data);
      updateParameters(data);
      $('#actions button').removeAttr('disabled');
    }
  });
};

function clear(name) {
  $('#parameters .' + name + ' input').val('');
}

function installHandler(name) {
  $('#parameters .' + name + ' input').keydown(function(event) {
    if (event.keyCode != '9' || event.keyCode != '16') { // Not tab or shift.
      hasBeenUpdated(name);
    }
  });
};

$(document).ready(function() {
  $.each(parameters, function(index, parameter) {
    clear(parameter);
    installHandler(parameter);
  });
});