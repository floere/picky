module Picky
  module Tasks
    class Javascripts

      define_method :initialize do |target = 'javascripts'|
        desc "Copy the latest client javascripts to '#{target}' (Give target dir to Picky::Tasks::Javascripts.new to change)."
        task :javascripts do
          target_dir = File.expand_path target, Dir.pwd
          source_dir = File.expand_path '../../../../javascripts/*.min.js', __FILE__

          puts "Copying javascript files from picky-client gem to target dir #{target_dir}"
          `cp -i #{source_dir} #{target_dir}`
        end
      end

    end
  end
end