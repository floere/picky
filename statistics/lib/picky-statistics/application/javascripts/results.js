function addOne(ary, thing) {
  ary.push({ x: Date.now(), y: thing });
  if (ary.length > 100) {
    ary.shift();
  }
}

function add(data, r1, r2, r3, r4, r100, r1000, r0) {
  var total = r1 + r2 + r3 + r4 + r100 + r1000 + r0;
  if (total > 0) {
    addOne(data[0], r1/total);
    addOne(data[1], r2/total);
    addOne(data[2], r3/total);
    addOne(data[3], r4/total);
    addOne(data[4], r100/total);
    addOne(data[5], r1000/total);
    addOne(data[6], r0/total);
  }
}

var data = [ [], [], [], [], [], [], [] ];
add(data, 1, 1, 1, 1, 1, 1, 1);

var palette = new Rickshaw.Color.Palette( { scheme: 'spectrum2000' } );

palette.color();
palette.color();
palette.color();
palette.color();
palette.color();
palette.color();
palette.color();

var graph = new Rickshaw.Graph( {
  element: document.querySelector('#results_graph.stats .graph'),
  width: 900,
  height: 150,
  renderer: 'stack',
  offset: 'expand',
  series: [
    {
      color: palette.color(),
      data: data[0],
      name: '1 result'
    }, {
      color: palette.color(),
      data: data[1],
      name: '2 results'
    }, {
      color: palette.color(),
      data: data[2],
      name: '3 results'
    }, {
      color: palette.color(),
      data: data[3],
      name: '4 or more results'
    }, {
      color: palette.color(),
      data: data[4],
      name: '100 or more results'
    }, {
      color: palette.color(),
      data: data[5],
      name: '1000 or more results'
    }, {
      color: palette.color(),
      data: data[6],
      name: 'no results'
    }
  ]
} );

var legend = new Rickshaw.Graph.Legend( {
 graph: graph,
 element: document.querySelector('#results_graph.stats .legend')
});

new Rickshaw.Graph.Behavior.Series.Highlight( {
 graph: graph,
 legend: legend
});

// new Rickshaw.Graph.HoverDetail( {
//  graph: graph
// });

updateNewResults = function(r1, r2, r3, r4, r100, r1000, r0) {
  add(data, r1, r2, r3, r4, r100, r1000, r0);
  graph.update();
};