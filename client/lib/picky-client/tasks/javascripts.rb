module Picky

  # Rake tasks for Picky clients.
  #
  module Tasks

    # Copies the latest javascripts into the default javascript folder.
    #
    # Example:
    #   # Use as follows in your Rakefile.
    #   #
    #   Picky::Tasks::Javascripts.new                       # Copies the files into the javascripts folder (by default).
    #   Picky::Tasks::Javascripts.new('public/javascripts') # Copies the files into the public/javascripts folder.
    #
    class Javascripts

      define_method :initialize do |*args|
        target = args.shift || 'javascripts'
        desc "Copy the latest client javascripts to '#{target}' (Give target dir to Picky::Tasks::Javascripts.new to change)."
        task :javascripts do
          target_dir = ::File.expand_path target, Dir.pwd
          source_dir = ::File.expand_path '../../../../javascripts/*.min.js', __FILE__

          puts "Copying javascript files from picky-client gem to target dir #{target_dir}"
          `cp -i #{source_dir} #{target_dir}`
        end
      end

    end
  end
end