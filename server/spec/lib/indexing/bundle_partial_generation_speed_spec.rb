# require 'spec_helper'
#
# describe Picky::Bundle do
#
#   before(:each) do
#     @index            = Picky::Index.new :some_index
#     @category         = Picky::Category.new :some_category, @index
#
#     @partial_strategy = Picky::Generators::Partial::Substring.new :from => 1
#     @exact            = described_class.new :some_name, @category, Picky::Backends::Memory.new, nil, @partial_strategy, nil
#   end
#
#   def generate_random_keys amount
#     alphabet = ('a'..'z').to_a
#     (1..amount).to_a.collect! do |n|
#       Array.new(20).collect! { alphabet[rand(26)] }.join.to_sym
#     end
#   end
#   def generate_random_ids amount
#     (1..amount).to_a.collect! do |_|
#       Array.new(rand(100)+5).collect! do |_|
#         rand(5_000_000)
#       end
#     end
#   end
#
#   describe 'speed' do
#     context 'medium arrays' do
#       before(:each) do
#         random_keys     = generate_random_keys 300
#         random_ids      = generate_random_ids  300
#         @exact.inverted = Hash[random_keys.zip(random_ids)]
#       end
#       it 'should be fast' do
#         performance_of do
#           @exact.generate_partial
#         end.should < 0.1
#       end
#     end
#   end
#
# end