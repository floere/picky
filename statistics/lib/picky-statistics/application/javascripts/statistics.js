var intervalUpdating = false;

function updateStatistics() {
  // $.ajax({
  //   url: 'index.json',
  //   beforeSend: function() {
  //     $('body .actions').css('background-color', '#eec');
  //   },
  //   success: function(data) {
  //     // alert(data);
  //     data = $.parseJSON(data);
  //     // updateFullLive(data);
  //     // updateResults(data);
  //     // updateOffset(data);
  //     // updateSpeed(data);
  //     if (intervalUpdating) {
  //       $('body .actions').css('background-color', '#eee');
  //     } else {
  //       $('body .actions').css('background-color', 'white');
  //     };
  //   }
  // });
};

var periodicalUpdaterId;

function updateStatisticsPeriodically(seconds) {
  clearInterval(periodicalUpdaterId);
  periodicalUpdaterId = setInterval(function() {
       updateStatistics();
  }, 1000*seconds);
  intervalUpdating = true;
  // $('body .actions').css('background-color', '#eee');
};

function stopUpdatingStatistics() {
  clearInterval(periodicalUpdaterId);
  intervalUpdating = false;
  // $('body .actions').css('background-color', 'white');
};

d3.json("index.json", function(searches) {

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

  var minTotal = 10000000000000;
  var maxTotal = 0;

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
      
    if (d.total >= maxTotal) {
      maxTotal = d.total;
    }
    if (d.total <= minTotal) {
      minTotal = d.total;
    }
  });

  // Create the crossfilter for the relevant dimensions and groups.
  //
  var search = crossfilter(searches),
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
      .x(d3.scale.linear()
        .domain([minTotal, maxTotal+1])
        .rangeRound([0, 1000])),
      
    barChart()
        .dimension(allocation)
        .group(allocations)
      .x(d3.scale.linear()
        .domain([0, 20])
        .rangeRound([0, 1000])),
      
    barChart()
        .dimension(offset)
        .group(offsets)
      .x(d3.scale.linear()
        .domain([0, 200])
        .rangeRound([0, 1000])),

    barChart()
        .dimension(duration)
        .group(durations)
      .x(d3.scale.linear()
        .domain([0, 0.001])
        .rangeRound([0, 1000]))
  ];

  // Given our array of charts, which we assume are in the same order as the
  // .chart elements in the DOM, bind the charts to the DOM and render them.
  // We also listen to the chart's brush events to update the display.
  //
  var chart = d3.selectAll(".chart")
      .data(charts)
      .each(function(chart) { chart.on("brush", renderAll).on("brushend", renderAll); });

  // Render the initial lists.
  //
  var list = d3.selectAll(".list")
      .data([searchList]);

  // Render the total.
  //
  d3.selectAll("#total")
      .text(formatNumber(search.size()));

  renderAll();

  // Renders the specified chart or list.
  //
  function render(method) {
    d3.select(this).call(method);
  }

  // Whenever the brush moves, re-rendering everything.
  //
  function renderAll() {
    chart.each(render);
    list.each(render);
    d3.select("#active").text(formatNumber(all.value()));
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

  function searchList(div) {
    var searchesByDate = nestByDate.entries(date.top(40));

    div.each(function() {
      var date = d3.select(this).selectAll(".date")
          .data(searchesByDate, function(d) { return d.key; });

      date.enter().append("div")
          .attr("class", "date")
        .append("h2")
          .attr("class", "day")
          .text(function(d) { return formatDate(d.values[0].date); });

      date.exit().remove();

      var search = date.order().selectAll(".search")
          .data(function(d) { return d.values; }, function(d) { return d.index; });

      var searchEnter = search.enter().append("div")
          .attr("class", "search");         

      searchEnter.append("div")
          .attr("class", "time")
          .text(function(d) { return formatTime(d.date); });
        
      searchEnter.append("div").text("Found");
        
      searchEnter.append("div")
          .attr("class", "total")
          .text(function(d) { return formatNumber(d.total); });
        
      searchEnter.append("div").text(":");
        
      searchEnter.append("div")
          .attr("class", "text")
          .text(function(d) { return d.text; });

      searchEnter.append("div").text("# alc");
            
      searchEnter.append("div")
          .attr("class", "allocation")
          .text(function(d) { return formatNumber(d.allocations); });
            
      searchEnter.append("div").text("/ off");
            
      searchEnter.append("div")
          .attr("class", "offset")
          .text(function(d) { return formatNumber(d.offset); });
        
      searchEnter.append("div").text("in");
        
      searchEnter.append("div")
          .attr("class", "duration")
          .text(function(d) { return formatFloat(d.duration); });
        
      searchEnter.append("div").text("s");

      search.exit().remove();

      search.order();
    });
  }
  
  // A bar chart.
  //
  function barChart() {
    if (!barChart.id) barChart.id = 0;

    var margin = {top: 10, right: 10, bottom: 20, left: 10},
        x,
        y = d3.scale.linear().range([100, 0]),
        id = barChart.id++,
        axis = d3.svg.axis().orient("bottom"),
        brush = d3.svg.brush(),
        brushDirty,
        dimension,
        group,
        round;

    function chart(div) {
      var width = x.range()[1],
          height = y.range()[0];

      y.domain([0, group.top(1)[0].value]);

      div.each(function() {
        var div = d3.select(this),
            g = div.select("g");

        // Create the skeletal chart.
        if (g.empty()) {
          div.select(".title").append("a")
              .attr("href", "javascript:reset(" + id + ")")
              .attr("class", "reset")
              .text("reset")
              .style("display", "none");

          g = div.append("svg")
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom)
            .append("g")
              .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

          g.append("clipPath")
              .attr("id", "clip-" + id)
            .append("rect")
              .attr("width", width)
              .attr("height", height);

          g.selectAll(".bar")
              .data(["background", "foreground"])
            .enter().append("path")
              .attr("class", function(d) { return d + " bar"; })
              .datum(group.all());

          g.selectAll(".foreground.bar")
              .attr("clip-path", "url(#clip-" + id + ")");

          g.append("g")
              .attr("class", "axis")
              .attr("transform", "translate(0," + height + ")")
              .call(axis);

          // Initialize the brush component with pretty resize handles.
          var gBrush = g.append("g").attr("class", "brush").call(brush);
          gBrush.selectAll("rect").attr("height", height);
          gBrush.selectAll(".resize").append("path").attr("d", resizePath);
        }

        // Only redraw the brush if set externally.
        if (brushDirty) {
          brushDirty = false;
          g.selectAll(".brush").call(brush);
          div.select(".title a").style("display", brush.empty() ? "none" : null);
          if (brush.empty()) {
            g.selectAll("#clip-" + id + " rect")
                .attr("x", 0)
                .attr("width", width);
          } else {
            var extent = brush.extent();
            g.selectAll("#clip-" + id + " rect")
                .attr("x", x(extent[0]))
                .attr("width", x(extent[1]) - x(extent[0]));
          }
        }

        g.selectAll(".bar").attr("d", barPath);
      });

      function barPath(groups) {
        var path = [],
            i = -1,
            n = groups.length,
            d;
        while (++i < n) {
          d = groups[i];
          path.push("M", x(d.key), ",", height, "V", y(d.value), "h9V", height);
        }
        return path.join("");
      }

      function resizePath(d) {
        var e = +(d == "e"),
            x = e ? 1 : -1,
            y = height / 3;
        return "M" + (.5 * x) + "," + y
            + "A6,6 0 0 " + e + " " + (6.5 * x) + "," + (y + 6)
            + "V" + (2 * y - 6)
            + "A6,6 0 0 " + e + " " + (.5 * x) + "," + (2 * y)
            + "Z"
            + "M" + (2.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8)
            + "M" + (4.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8);
      }
    }

    brush.on("brushstart.chart", function() {
      var div = d3.select(this.parentNode.parentNode.parentNode);
      div.select(".title a").style("display", null);
    });

    brush.on("brush.chart", function() {
      var g = d3.select(this.parentNode),
          extent = brush.extent();
      if (round) g.select(".brush")
          .call(brush.extent(extent = extent.map(round)))
        .selectAll(".resize")
          .style("display", null);
      g.select("#clip-" + id + " rect")
          .attr("x", x(extent[0]))
          .attr("width", x(extent[1]) - x(extent[0]));
      dimension.filterRange(extent);
    });

    brush.on("brushend.chart", function() {
      if (brush.empty()) {
        var div = d3.select(this.parentNode.parentNode.parentNode);
        div.select(".title a").style("display", "none");
        div.select("#clip-" + id + " rect").attr("x", null).attr("width", "100%");
        dimension.filterAll();
      }
    });

    chart.margin = function(_) {
      if (!arguments.length) return margin;
      margin = _;
      return chart;
    };

    chart.x = function(_) {
      if (!arguments.length) return x;
      x = _;
      axis.scale(x);
      brush.x(x);
      return chart;
    };

    chart.y = function(_) {
      if (!arguments.length) return y;
      y = _;
      return chart;
    };

    chart.dimension = function(_) {
      if (!arguments.length) return dimension;
      dimension = _;
      return chart;
    };

    chart.filter = function(_) {
      if (_) {
        brush.extent(_);
        dimension.filterRange(_);
      } else {
        brush.clear();
        dimension.filterAll();
      }
      brushDirty = true;
      return chart;
    };

    chart.group = function(_) {
      if (!arguments.length) return group;
      group = _;
      return chart;
    };

    chart.round = function(_) {
      if (!arguments.length) return round;
      round = _;
      return chart;
    };

    return d3.rebind(chart, brush, "on");
  }
});