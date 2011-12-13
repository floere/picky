// function add(r1, r2, r3, r4, r100, r1000, r0) {
//   var total = r1 + r2 + r3 + r4 + r100 + r1000 + r0;
//   return {
//     time: ++t,
//     r1: (r1/total),
//     r2: (r2/total)
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
// var chart = d3.select("#results_graph.stats .graph")
//               .append("svg:svg")
//                 .attr("class", "chart")
//                 .attr("width", w * data.length - 1)
//                 .attr("height", h);
// 
// chart.selectAll("rect")
//   .data(data)
//   .enter().append("svg:rect")
//   .attr("x", function(d, i) { return x(i) - 0.5; })
//   .attr("y", function(d) { return h - y(d.r1) - 0.5; })
//   .attr("width", w)
//   .attr("height", function(d) { return y(d.r1); });
// 
// chart.append("svg:line")
//      .attr("x1", 0)
//      .attr("x2", w * data.length)
//      .attr("y1", h - 0.5)
//      .attr("y2", h - 0.5)
//      .attr("stroke", "#000");
// 
// function redraw() {
//   var rect = chart.selectAll("rect")
//                   .data(data, function(d) { return d.time; });
//   
//   rect.enter().insert("svg:rect", "line")
//       .attr("x", function(d, i) { return x(i + 1) - 0.5; })
//       .attr("y", function(d) { return h - y(d.r1) - 0.5; })
//       .attr("width", w)
//       .attr("height", function(d) { return y(d.r1); })
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

updateNewResults = function(r1, r2, r3, r4, r100, r1000, r0) {
  // data.shift();
  // data.push(add(r1, r2, r3, r4, r100, r1000, r0));
  // redraw();
};