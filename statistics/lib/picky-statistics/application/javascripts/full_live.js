function add(data, full, live) {
  var total = full + live;
  data[0].push({ x: Date.now(), y: (full/total) });
  if (data[0].length > 100) {
    data[0].shift();
  }
  data[1].push({ x: Date.now(), y: (live/total) });
  if (data[1].length > 100) {
    data[1].shift();
  }
}

var data = [ [], [] ];

add(data, 1, 1);

var graph = new Rickshaw.Graph( {
  element: document.querySelector('#full_live_graph.stats .graph'),
  width: 900,
  height: 150,
  renderer: 'stack',
  offset: 'expand',
  series: [
    {
      color: 'steelblue',
      data: data[0]
    }, {
      color: 'lightblue',
      data: data[1]
    }
  ]
} );

updateNewFullLive = function(full, live) {
  add(data, full, live);
  graph.render();
};

// function add(full, live) {
//   var total = full + live;
//   return {
//     time: ++t,
//     full: full/total,
//     live: live/total
//   };
// }
// 
// var t = 1297110663,                // start time (seconds since epoch)
//     v = 70,                        // start value (subscribers)
//     data = d3.range(33).map(add); // starting dataset
// 
// var w = 20,
//     h = 80;
// 
// var x = d3.scale.linear()
//           .domain([0, 1])
//           .range([0, w]);
// 
// var y = d3.scale.linear()
//           .domain([0, 1])
//           .rangeRound([0, h]);
// 
// var chart = d3.select("#full_live_graph.stats .graph")
//               .append("svg:svg")
//                 .attr("class", "chart")
//                 .attr("width", w * data.length - 1)
//                 .attr("height", h);
// 
// chart.append("svg:line")
//      .attr("x1", 0)
//      .attr("x2", w * data.length)
//      .attr("y1", h - 0.5)
//      .attr("y2", h - 0.5)
//      .attr("stroke", "#000");
// 
// function redraw() {
//   var rect = chart.selectAll("rect.full")
//                   .data(data, function(d) { return d.time; });
//   
//   rect.enter().insert("svg:rect", "line")
//       .attr("x", function(d, i) { return x(i + 1) - 0.5; })
//       .attr("y", function(d) { return h - y(d.full) - 0.5; })
//       .attr("width", w)
//       .attr("height", function(d) { return y(d.full); })
//     .transition()
//       .duration(1000)
//       .attr("x", function(d, i) { return x(i) - 0.5; });
// 
//   rect.transition()
//       .duration(1000)
//       .attr("x", function(d, i) { return x(i) - 0.5; });
// 
//   rect.exit().transition()
//       .duration(1000)
//       .attr("x", function(d, i) { return x(i - 1) - 0.5; })
//       .remove();
// }
// 
// updateNewFullLive = function(full, live) {
//   data.push(add(full, live));
//   data.shift();
//   redraw();
// };