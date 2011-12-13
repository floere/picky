function addOne(ary, thing) {
  ary.push({ x: Date.now(), y: thing });
  if (ary.length > 100) {
    ary.shift();
  }
}

function add(data, full, live) {
  var total = full + live;
  addOne(data[0], full/total);
  addOne(data[1], live/total);
}

var data = [ [], [] ];
add(data, 1, 1);

var palette = new Rickshaw.Color.Palette( { scheme: 'spectrum2000' } );

palette.color();
palette.color();
palette.color();
palette.color();

var graph = new Rickshaw.Graph( {
  element: document.querySelector('#full_live_graph.stats .graph'),
  width: 900,
  height: 150,
  renderer: 'stack',
  offset: 'expand',
  series: [
    {
      color: palette.color(),
      data: data[0],
      name: 'Full'
    }, {
      color: palette.color(),
      data: data[1],
      name: 'Live'
    }
  ]
} );

var legend = new Rickshaw.Graph.Legend( {
	graph: graph,
	element: document.querySelector('#full_live_graph.stats .legend')
});

new Rickshaw.Graph.Behavior.Series.Highlight( {
	graph: graph,
	legend: legend
});

// new Rickshaw.Graph.HoverDetail( {
//  graph: graph
// });

updateNewFullLive = function(full, live) {
  add(data, full, live);
  graph.update();
};