var fullLiveGraph = new Graph('#full_live_graph.stats', ['Full', 'Live'], 4);
var resultsGraph  = new Graph('#results_graph.stats', ['1 result', '2 results', '3 results', '4 or more results', '100 or more results', '1000 or more results', 'no results'], 7);
var speedGraph  = new Graph('#speed_graph.stats', ['quick (< 0.001s)', 'normal', 'slow (> 0.1s)', 'very slow (> 1s)'], 10);
var offsetsGraph  = new Graph('#offset_graph.stats', ['with offset', 'without offset'], 3);

function updateFullLive(data) {
  fullLiveGraph.update([
    parseInt(data["full"]["total"], 10),
    parseInt(data["live"]["total"], 10)
  ]);
};

function updateResults(data) {
  resultsGraph.update([
    parseInt(data["full"]["totals"][1], 10),
    parseInt(data["full"]["totals"][2], 10),
    parseInt(data["full"]["totals"][3], 10),
    parseInt(data["full"]["totals"]['4+'], 10),
    parseInt(data["full"]["totals"]['100+'], 10),
    parseInt(data["full"]["totals"]['1000+'], 10),
    parseInt(data["full"]["totals"][0], 10)
  ]);
};

function updateSpeed(data) {
  var total = parseInt(data["full"]["total"], 10);
  var quick = parseInt(data["full"]["quick"], 10);
  var long_running = parseInt(data["full"]["long_running"], 10);
  var very_long_running = parseInt(data["full"]["very_long_running"], 10);
  
  speedGraph.update([
    quick,
    (total - quick - long_running - very_long_running),
    long_running,
    very_long_running
  ]);
};

function updateOffset(data) {
  var withOffset    = parseInt(data["full"]["offset"], 10);
  var total         = parseInt(data["full"]["total"], 10);
  var withoutOffset = total - withOffset;
  
  offsetsGraph.update([
    withOffset,
    withoutOffset
  ]);
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