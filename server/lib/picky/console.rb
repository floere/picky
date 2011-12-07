#!/usr/bin/env ruby
# encoding: utf-8
#
module Picky

  # Handles the IRB console for Picky.
  #
  class Console

    def self.start args = ARGV
      irb = 'irb'

      require 'optparse'
      options = { :sandbox => false, :irb => irb }
      OptionParser.new do |opt|
        opt.banner = "Usage: console [environment] [options]"
        opt.on("--irb=[#{irb}]", 'Invoke a different irb.') { |v| options[:irb] = v }
        opt.parse!(args)
      end

      libs =  " -r irb/completion"
      libs << %( -r "#{File.expand_path('../../picky.rb', __FILE__)}" )

      mapping = {
        'p' => 'production',
        'd' => 'development',
        't' => 'test'
      }
      given_env = args.first
      ENV['PICKY_ENV'] = mapping[given_env] || given_env || ENV['PICKY_ENV'] || 'development'

      puts "Use \x1b[1;30mPicky::Loader.load_application\x1b[m to load app."
      puts "Use \x1b[1;30mPicky::Indexes.load\x1b[m after that to load indexes."
      puts "Copy the following line to do just that:"
      puts "\x1b[1;30mPicky::Loader.load_application; Picky::Indexes.load; p\x1b[m"
      exec "#{options[:irb]} #{libs} --simple-prompt"
    end

  end

end