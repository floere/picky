function Graph(selector, names, palette_offset) {
  
  var graph_element  = document.querySelector(selector + ' .graph');
  var legend_element = document.querySelector(selector + ' .legend');
  
  function addOne(ary, thing) {
    ary.push({ x: Date.now(), y: thing });
    if (ary.length > 100) {
      ary.shift();
    }
  }

  function add(data, params) {
    for(var i=0,total=0;i<params.length;total+=params[i++]);
    if (total > 0) {
      for (i = 0; i < params.length; i++) {
        addOne(data[i], params[i]/total);
      }
    }
  }
  
  var data = [];
  var init = [];
  for (var i = 0; i < names.length; i++) {
    data.push([]);
    init.push(1);
  }
  
  // add(data, init);

  var palette = new Rickshaw.Color.Palette( { scheme: 'spectrum2000' } );
  for (i = 0; i < palette_offset; i++) {
    palette.color();
  }
  
  var series = [];
  for (i = 0; i < names.length; i++) {
    series.push({
      color: palette.color(),
      data: data[i],
      name: names[i]
    });
  }

  var graph;
  
  var lazyInitializeGraph = function() {
    if (!graph) {
      graph = new Rickshaw.Graph( {
        element: graph_element,
        width: 900,
        height: 150,
        renderer: 'stack',
        offset: 'expand',
        series: series
      });

      var legend = new Rickshaw.Graph.Legend( {
      	graph: graph,
      	element: legend_element
      });

      new Rickshaw.Graph.Behavior.Series.Highlight( {
      	graph: graph,
      	legend: legend
      });

      // new Rickshaw.Graph.HoverDetail( {
      //  graph: graph
      // });
      
      graph.render();
    }
  };
  
  var update = function(new_data) {
    add(data, new_data);
    lazyInitializeGraph();
    graph.update();
  };
  this.update = update;
  
};