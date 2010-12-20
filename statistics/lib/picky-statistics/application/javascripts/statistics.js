var pieOptions = {
  type: 'pie',
  width: '100px',
  height: '100px',
  offset: -90
};

function updateFullLive(data) {
  pieOptions['sliceColors'] = ['#000000','#999999'];
  $('#full_live_graph.inlinesparkline').html([
    data["full"]["total"],
    data["live"]["total"]
  ].join(',')).sparkline('html', pieOptions);
}

function updateResults(data) {
  pieOptions['sliceColors'] = ['#66CC00','#669900','#666600','#996600','#FF9900','#FF9933','#CC0000'];
  $('#results_graph.inlinesparkline').html([
    data["full"]["totals"][1],
    data["full"]["totals"][2],
    data["full"]["totals"][3],
    data["full"]["totals"]['four_plus'],
    data["full"]["totals"]['100+'],
    data["full"]["totals"]['1000+'],
    data["full"]["totals"][0]
  ].join(',')).sparkline('html', pieOptions);
}

function updateOffset(data) {
  pieOptions['sliceColors'] = ['#000000','#999999'];
  $('#offset_graph.inlinesparkline').html([
    data["full"]["offset"],
    data["full"]["total"]
  ].join(',')).sparkline('html', pieOptions);
}

function updateSpeed(data) {
  pieOptions['sliceColors'] = ['#66CC00','#669900','#996600','#CC0000'];
  var total = parseInt(data["full"]["total"]);
  var quick = parseInt(data["full"]["quick"]);
  var long_running = parseInt(data["full"]["long_running"]);
  var very_long_running = parseInt(data["full"]["very_long_running"]);
  $('#speed_graph.inlinesparkline').html([
    quick,
    (total - quick - long_running - very_long_running),
    long_running,
    very_long_running
  ].join(',')).sparkline('html', pieOptions);
}

function updateStatistics() {
  $.ajax({
    url: 'index.json',
    beforeSend: function() {
      $('.inlinesparkline').css('background-color', '#eee');
    },
    success: function(data) {
      // alert(data);
      data = $.parseJSON(data);
      updateFullLive(data);
      updateResults(data);
      updateOffset(data);
      updateSpeed(data);
      $('.inlinesparkline').css('background-color', 'white');
    }
  });
};

function updateStatisticsPeriodically(seconds) {
  var refreshId = setInterval(function() {
       updateStatistics();
  }, 1000*seconds);
};