# Routing tasks.
#
desc "Shows the available URL paths."
task :routes => :application do
  Application.apps.each do |app|
    puts app.to_routes
  end
end