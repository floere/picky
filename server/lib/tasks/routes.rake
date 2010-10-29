desc "Shows the available URL paths"
task :routes => :application do
  puts "Note: Anchored (\u2713) regexps are faster, e.g. /\\A.*\\Z/ or /^.*$/.\n\n"
  Application.apps.each do |app|
    p app
  end
end