function updateParameters(data) {
  $('#parameters .querying_removes_characters').val(data['querying_removes_characters']);
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