require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'picky-client'

PickyBackend = Picky::Client::Full.new :host => 'localhost', :port => 4000, :path => '/books/full'

get '/javascripts/:file_name' do
  f = File.open("javascripts/#{params[:file_name]}")
  result = f.read
  f.close
  result
end

get '/' do
  PickyBackend.search :query => params[:query]
  
  wrap_in_html Picky::Helper.interface
end

get '/search/live' do
  params.inspect
end

get '/search/full' do
  params.inspect
end

def wrap_in_html interface
  javascripts = []
  javascripts << 'jquery-1.3.2.js'
  javascripts << 'jquery.timer.js'
  javascripts << 'picky.translations.js'
  javascripts << 'picky.config.js'
  javascripts << 'picky.view.js'
  javascripts << 'picky.backend.js'
  javascripts << 'picky.controller.js'
  javascripts << 'picky.client.js'
  javascripts = javascripts.map { |js_file| "<script src='javascripts/#{js_file}' type='text/javascript'></script>" }.join
  <<-HTML
<html>
  <head>
    #{javascripts}
  </head>
  <body>
    #{interface}
    <script type='text/javascript'>
      //<![CDATA[
        pickyClient = new PickyClient({
          controller: PickyController,
          backends: {
            live: new LiveBackend('/search/live'),
            full: new FullBackend('/search/full')
          },
          locale: PickyI18n.locale,
          showResultsThreshold: 10,
          showFeedback: true,
          before: function(params) {  }, // mess with the params before sending. params['hello'] = 'blaaah'; return params
          success: function(data) {  },
          after: function(data) {  },
          keyUp: function(event) { }
        });
      //]]>
    </script>
  </body>
</html>
HTML
end