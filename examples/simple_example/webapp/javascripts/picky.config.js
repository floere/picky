var PickyConfig = function(){
  //

  var config = {
      controller: PickyController,
      backends: {
        live: LiveBackend,
        full: FullBackend
      },
      locale: PickyI18n.locale,
      showResultsThreshold: 10,
      showFeedback: true
    };
    
  // var specializedConfig = { ...
    
  this.mainConfig = function() {
    return main;
  };
  
  // this.specializedConfig = function() {
  //   return $.extend(main, specializedConfig);
  // };
  
  this.find = {
    config: config
  };

};