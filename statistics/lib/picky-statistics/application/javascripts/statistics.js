// TODO Refactor the file.
//

var pieOptions = {
  type: 'pie',
  width: '100px',
  height: '100px',
  offset: -90
};

function updateFullLive(data) {
  // var values = [
  //   data["full"]["total"],
  //   data["live"]["total"]
  // ];
  // pieOptions['sliceColors'] = ['#000000','#999999'];
  // $('#full_live_graph .inlinesparkline').sparkline(values, pieOptions);
  // $('#full_live_graph .legend .full').html(data["full"]["total"]);
  // $('#full_live_graph .legend .live').html(data["live"]["total"]);
  // $('#full_live_graph .legend .total').html(parseInt(data["full"]["total"], 10) + parseInt(data["live"]["total"], 10));
  
  updateNewFullLive(
    parseInt(data["full"]["total"], 10),
    parseInt(data["live"]["total"], 10)
  );
};

function updateResults(data) {
  updateNewResults(
    parseInt(data["full"]["totals"][1], 10),
    parseInt(data["full"]["totals"][2], 10),
    parseInt(data["full"]["totals"][3], 10),
    parseInt(data["full"]["totals"]['4+'], 10),
    parseInt(data["full"]["totals"]['100+'], 10),
    parseInt(data["full"]["totals"]['1000+'], 10),
    parseInt(data["full"]["totals"][0], 10)
  );
};

function updateOffset(data) {
  var withOffset    = parseInt(data["full"]["offset"], 10);
  var total         = parseInt(data["full"]["total"], 10);
  var withoutOffset = total - withOffset;
  
  var values = [
    withOffset,
    withoutOffset
  ];
  pieOptions['sliceColors'] = ['#000000','#999999'];
  $('#offset_graph .inlinesparkline').sparkline(values, pieOptions);
  $('#offset_graph .legend .with_offset').html(withOffset);
  $('#offset_graph .legend .without_offset').html(withoutOffset);
};

function updateSpeed(data) {
  var total = parseInt(data["full"]["total"], 10);
  var quick = parseInt(data["full"]["quick"], 10);
  var long_running = parseInt(data["full"]["long_running"], 10);
  var very_long_running = parseInt(data["full"]["very_long_running"], 10);
  
  var values = [
    quick,
    (total - quick - long_running - very_long_running),
    long_running,
    very_long_running
  ];
  pieOptions['sliceColors'] = ['#66CC00','#669900','#FF9900','#CC0000'];
  $('#speed_graph .inlinesparkline').sparkline(values, pieOptions);
};

var intervalUpdating = false;

function updateStatistics() {
  $.ajax({
    url: 'index.json',
    beforeSend: function() {
      $('body .actions').css('background-color', '#eec');
    },
    success: function(data) {
      // alert(data);
      data = $.parseJSON(data);
      updateFullLive(data);
      updateResults(data);
      updateOffset(data);
      updateSpeed(data);
      if (intervalUpdating) {
        $('body .actions').css('background-color', '#eee');
      } else {
        $('body .actions').css('background-color', 'white');
      };
    }
  });
};

var periodicalUpdaterId;

function updateStatisticsPeriodically(seconds) {
  clearInterval(periodicalUpdaterId);
  periodicalUpdaterId = setInterval(function() {
       updateStatistics();
  }, 1000*seconds);
  intervalUpdating = true;
  $('body .actions').css('background-color', '#eee');
};

function stopUpdatingStatistics() {
  clearInterval(periodicalUpdaterId);
  intervalUpdating = false;
  $('body .actions').css('background-color', 'white');
};