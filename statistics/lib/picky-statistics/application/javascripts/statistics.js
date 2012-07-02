function showNotice() {
  var notice = document.getElementById('notice');
  if (notice != null) {
    notice.style.display = 'block';
  }
}
function hideNotice() {
  var notice = document.getElementById('notice');
  if (notice != null) {
    notice.style.display = 'none';
  }
}

// Various formatters.
//
var formatNumber = d3.format(",d"),
    formatFloat  = d3.format(".l")
    formatChange = d3.format("+,d"),
    formatDate = d3.time.format("%B %d, %Y"),
    formatTime = d3.time.format("%I:%M %p");

// A nest operator, for grouping the flight list.
//
var nestByDate = d3.nest()
    .key(function(d) { return d3.time.day(d.date); });

// Create the crossfilter for the relevant dimensions and groups.
//
var search = crossfilter(),
    all = search.groupAll(),
    date = search.dimension(function(d) { return d3.time.day(d.date); }),
    dates = date.group(),
    hour = search.dimension(function(d) { return d.date.getHours() + d.date.getMinutes() / 60; }),
    hours = hour.group(),
    total = search.dimension(function(d) { return d.total; }),
    totals = total.group();
    offset = search.dimension(function(d) { return d.offset; }),
    offsets = offset.group();
    allocation = search.dimension(function(d) { return d.allocations; }),
    allocations = allocation.group();
    duration = search.dimension(function(d) { return d.duration; }),
    durations = duration.group();

var chartWidth = [0, 1000];

var totalScale = d3.scale.linear()
      .domain([0, 0])
      .rangeRound(chartWidth);

var allocationsScale = d3.scale.linear()
      .domain([0, 0])
      .rangeRound(chartWidth);

var offsetScale = d3.scale.linear()
      .domain([0, 0])
      .rangeRound(chartWidth);
      
var durationScale = d3.scale.linear()
      .domain([0, 0])
      .rangeRound(chartWidth);

var charts = [

  // barChart()
  //     .dimension(date)
  //     .group(dates)
  //     .round(d3.time.day.round)
  //   .x(d3.time.scale()
  //     .domain([new Date(2001, 0, 1), new Date(2001, 3, 1)])
  //     .rangeRound([0, 10 * 90]))
  //     .filter([new Date(2001, 1, 1), new Date(2001, 2, 1)]),

  barChart()
      .dimension(hour)
      .group(hours)
    .x(d3.scale.linear()
      .domain([0, 24])
      .rangeRound([0, 1000])),

  barChart()
      .dimension(total)
      .group(totals)
    .x(totalScale),
      
  barChart()
      .dimension(allocation)
      .group(allocations)
    .x(allocationsScale),
      
  barChart()
      .dimension(offset)
      .group(offsets)
    .x(offsetScale),

  barChart()
      .dimension(duration)
      .group(durations)
    .x(durationScale)
];

// Renders the specified chart or list.
//
function render(method) {
  d3.select(this).call(method);
}

// Whenever the brush moves, re-rendering everything.
//
function renderAll() {
  // Given our array of charts, which we assume are in the same order as the
  // .chart elements in the DOM, bind the charts to the DOM and render them.
  // We also listen to the chart's brush events to update the display.
  //
  var chart = d3.selectAll(".chart")
      .data(charts)
      .each(function(chart) { chart.on("brush", renderAll).on("brushend", renderAll); });
  chart.each(render);
  
  // Render the initial lists.
  //
  var list = d3.selectAll(".list")
      .data([searchList]);
  list.each(render);
  
  // Render the total.
  //
  d3.selectAll("aside.totals .total")
      .text(formatNumber(search.size()));
  
  d3.selectAll("aside.totals .active").text(formatNumber(all.value()));
}

// Like d3.time.format, but faster.
//
function parseDate(d) {
  return new Date(
    d.substring(0, 4),
    d.substring(5, 7) - 1,
    d.substring(8, 10),
    d.substring(11, 13),
    d.substring(14, 16),
    d.substring(17, 19)
  );
}

window.filter = function(filters) {
  filters.forEach(function(d, i) { charts[i].filter(d); });
  renderAll();
};

window.reset = function(i) {
  charts[i].filter(null);
  renderAll();
};

var intervalUpdating = false;

function updateStatistics(reloadAll, seconds) {
  path = reloadAll ? 'index.json' : 'since_last.json';
  
  if (!seconds || seconds >= 30) { showNotice(); }
  
  d3.json(path, function(searches) {
    if (!searches || searches.length == 0) { return; }
    
    var totalMin = 1000000; // Highest minimum set to sane number.
    var totalMax = 0;
    var allocationsMin = 100; // Highest minimum set to sane number.
    var allocationsMax = 0;
    var offsetMin = 1000; // Highest minimum set to sane number.
    var offsetMax = 0;    
    var durationMin = 20; // Highest minimum set to sane number.
    var durationMax = 0;
    
    // A little coercion, since the CSV is untyped.
    //
    searches.forEach(function(d, i) {
      d.index = i;
      d.date = parseDate(d[0]);
      d.duration = Number(d[1]);
      d.text = d[2];
      d.total = Number(d[3]);
      d.offset = Number(d[4]);
      d.allocations = Number(d[5]);
      
      if (totalMin > d.total) { totalMin = d.total; }
      if (totalMax < d.total) { totalMax = d.total; }
      if (allocationsMin > d.allocations) { allocationsMin = d.allocations; }
      if (allocationsMax < d.allocations) { allocationsMax = d.allocations; }
      if (offsetMin > d.offset) { offsetMin = d.offset; }
      if (offsetMax < d.offset) { offsetMax = d.offset; }
      if (durationMin > d.duration) { durationMin = d.duration; }
      if (durationMax < d.duration) { durationMax = d.duration; }
    });
    
    // Set scales.
    //
    var totalDomain = totalScale.domain();
    totalScale.domain([d3.min([totalMin, totalDomain[0]])*0.9, d3.max([totalMax, totalDomain[1]])]);
    var allocationsDomain = allocationsScale.domain();
    allocationsScale.domain([d3.min([allocationsMin, allocationsDomain[0]])*0.9, d3.max([allocationsMax, allocationsDomain[1]])]);
    var offsetDomain = offsetScale.domain();
    offsetScale.domain([d3.min([offsetMin, offsetDomain[0]])*0.9, d3.max([offsetMax, offsetDomain[1]])]);
    var durationDomain = durationScale.domain();
    durationScale.domain([d3.min([durationMin, durationDomain[0]])*0.9, d3.max([durationMax, durationDomain[1]])]);
  
    search.add(searches);
  
    renderAll();
    
    if (!seconds || seconds >= 30) { hideNotice(); }
  });
};

var periodicalUpdaterId;

function updateStatisticsPeriodically(seconds) {
  clearInterval(periodicalUpdaterId);
  periodicalUpdaterId = setInterval(function() {
       updateStatistics(false, seconds);
  }, 1000*seconds);
  intervalUpdating = true;
};

function stopUpdatingStatistics() {
  clearInterval(periodicalUpdaterId);
  intervalUpdating = false;
};