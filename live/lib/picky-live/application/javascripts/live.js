function updateParameters(data) {
  $('#parameters').html(data['querying_removes_characters']);
};

function getParameters() {
  $.ajax({
    url: 'index.json',
    success: function(data) {
      data = $.parseJSON(data);
      updateParameters(data);
    }
  });
};