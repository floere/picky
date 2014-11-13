###
# Compass
###

# Susy grids in Compass
# First: gem install susy --pre
# require 'susy'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:

# With no layout
#
# page "/enterprise.html", :layout => 'enterprise'

# With alternative layout
# page "enterprise.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
#
helpers do
  @@mapping = { '/' => '/index.html' }
  def class_for url, klass = ''
    current_url = current_page.url
    current_url = @@mapping[current_url] || current_url
    if current_url == url
      "current #{klass}"
    else
      klass
    end
  end
end

set :build_dir, 'build'
set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

class SemanticHeadersRenderer < Redcarpet::Render::HTML
  
  # Removes any Maruku header ids and sets them as id attribute in the header.
  #
  def header(title, level)
    match = title.match(%r{({#.+})})
    id, processed_title = if match && id = match[1]
      title.gsub!(id, '')
      id.gsub!(%r{[{}#]}, '')
      [id, title]
    else
      [
        title.downcase.gsub(/[\s]/, '-').gsub(/\:/, ''),
        title
      ]
    end
    
    "<h#{level} id='#{id}'>#{processed_title}</h#{level}>"
  end
end

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true,
               smartypants: true,
               gh_blockcode: true,
               renderer: SemanticHeadersRenderer
set :haml, { ugly: true }

# Build-specific configuration
#
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  # activate :cache_buster

  # Use relative URLs
  # activate :relative_assets

  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher

  # Or use a different image path
  # set :http_path, "/Content/images/"
end