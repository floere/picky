require 'csv'
require 'sinatra/base'
require_relative '../lib/picky'
require_relative 'helpers'
require_relative 'source'

# Reopen class.
#
class Source
  def each(&block)
    i = 0
    CSV.open('data.csv').each do |args|
      block.call Thing.new(*args)
      break if (i += 1) == @amount
    end
  end
end

with = ->(amount) do
  Source.new amount
end

include Picky

require_relative 'searches'

backends = [
  Backends::Memory.new, # Pre-run.
  # Backends::Memory.new,
  # Backends::File.new,
  # Backends::SQLite.new,
  # Backends::Redis.new,
  # Backends::SQLite.new(realtime: true),
  # Backends::Redis.new(realtime: true),
]

definitions = []

# definitions << [Proc.new do
#   category :text1, weight: Picky::Weights::Constant.new
#   category :text2, weight: Picky::Weights::Constant.new
#   category :text3, weight: Picky::Weights::Constant.new
#   category :text4, weight: Picky::Weights::Constant.new
# end, :no_weights]

# TODO Why does the String count explode when using key_format :to_s?
#
definitions << [Proc.new do
  category :text1
  category :text2
  category :text3
  category :text4
  category :text5
end, :normal]

# definitions << [Proc.new do
#   key_format :to_i
#   category :text1
#   category :text2
#   category :text3
#   category :text4
#   category :text5
# end, :normal]

# definitions << [Proc.new do
#   category :text1, partial: Picky::Partial::Postfix.new(from: 1)
#   category :text2, partial: Picky::Partial::Postfix.new(from: 1)
#   category :text3, partial: Picky::Partial::Postfix.new(from: 1)
#   category :text4, partial: Picky::Partial::Postfix.new(from: 1)
# end, :full_partial]

GC.enable
GC::Profiler.enable
Picky.logger = Picky::Loggers::Silent.new

Searches.prepare

amount = 2_000

def mark(klass = String)
  GC.start
  $marked = ObjectSpace.each_object(klass).to_a
  if block_given?
    yield
    diff klass
  end
end

def diff(klass = String)
  return unless $marked

  now_hash = Hash.new 0
  now = ObjectSpace.each_object(klass).to_a
  now.each { |thing| now_hash[thing] += 1 }

  $marked.each do |thing|
    now_hash[thing] -= 1
  end

  now_hash.select { |_, v| v > 0 }
end

definitions.each do |definition, description|
  # xxs = Index.new :xxs, &definition
  # xxs.source { with[10] }
  # xs  = Index.new :xs,  &definition
  # xs.source  { with[100] }
  # s   = Index.new :s,   &definition
  # s.source   { with[1_000] }
  m = Index.new :m, &definition
  m.source { with[10_000] }
  # l   = Index.new :l,   &definition
  # l.source   { with[100_000] }
  # xl  = Index.new :xl,  &definition
  # xl.source  { with[1_000_000] }

  puts
  puts
  puts "Running tests with definition #{description}."

  backends.each do |backend|
    puts
    puts backend.class
    puts ' Amount,  1wQ/s,  2wQ/s,  3wQ/s,  4wQ/s,  5wQ/s    Memory etc.'

    Indexes.each do |data|
      data.prepare if backend == backends.first

      data.backend backend
      data.clear
      data.cache
      data.load

      print '%7d' % data.source.amount

      rams = []
      strings = []
      gc_runs = []

      # Run amount queries, but only chosen from searches that will return a result.
      # (i.e. if the index is only 10 entries large, then 10 different queries will be run 100 times)
      #
      Searches.each(data.source.amount) do |queries|
        run = Search.new data
        # run.terminate_early
        # run.max_allocations 1 # Multiple allocations lead to the use of far more strings with larger indexes.

        # What Strings are created newly?
        #
        # GC.start
        # type = String
        # run.search "cleaning"
        # things = ObjectSpace.each_object(type).to_a
        # p strings # Interesting.
        # puts
        # puts
        # 1.times {
        #   1.times { run.search "text1:n" }
        #   1.times { run.search "text1:o text2:p" } # queries.to_a.first }
        #   1.times { run.search "a"*20 + " " + "b"*20 + " " + "c"*20 } # queries.to_a.first }
        # }
        # new_strings = ObjectSpace.each_object(type).to_a
        #
        # new_strings_hash = Hash.new 0
        # new_strings.each { |word| new_strings_hash[word] += 1 }
        #
        # things.each do |string|
        #   new_strings_hash[string] -= 1
        # end
        # puts
        # puts
        # require 'pp'
        # pp new_strings_hash.select { |k, v| v > 0 }
        # exit
        #
        #

        # Quick sanity check.
        #
        # fail if run.search(queries.each { |query| p query; break query }).ids.empty?

        searches = queries.first amount

        GC.start

        searches.each do |query|
          p query
          # mark
          run.search query
          # GC.start
          # d = diff
          # unless d.empty?
          #   p d
          #   p r.to_hash
          # end
          puts '.'
        end

        GC.start

        last_gc = runs
        searches.each do |query|
          run.search query
        end
        gc_runs << (runs - last_gc)

        duration = performance_of do
          searches.each do |query|
            run.search query
          end
        end

        GC.disable

        initial_ram = ram __FILE__
        searches.each do |query|
          run.search query
        end
        rams << (ram(__FILE__) - initial_ram)

        initial_strings = string_count
        searches.each do |query|
          run.search query
        end
        strings << (string_count - initial_strings)

        GC.enable

        print ', '
        print '%6d' % (amount / duration) # "%2.4f" % (duration*1000/amount)
      end

      print '   '
      print '%5d' % rams.sum
      print 'K '
      print '('
      print rams.map { |s| '%6d' % s }.join(', ')
      print ')'
      print '  %6d ' % (strings.sum / amount.to_f)
      print 'Strings '
      print '('
      print strings.map { |s| '%4.1f' % (s / amount.to_f) }.join(', ')
      print ')'
      print ' %2d' % gc_runs.sum
      puts
    end
  end
end
