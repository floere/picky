# require 'spec_helper'
# 
# describe Query::Solr do
# 
#   describe 'real server' do
#     before(:each) do
#       @server = Query::Solr.new
#     end
# 
#     describe 'execute' do
#       context 'error cases' do
#         before(:each) do
#           @tokens = double :tokens
#         end
#         context 'tokens are malformed' do
# 
#         end
#         context 'server returns strange values' do
# 
#         end
#         context 'server raises' do
#           before(:each) do
#             @server.stub :select => lambda { raise Solr::RequestError }
#           end
#           it 'should not fail' do
#             @tokens.stub :to_solr_query => ''
# 
#             lambda { @server.execute(@tokens) }.should_not raise_error
#           end
#         end
#       end
#     end
#   end
# 
#   context 'with connected Server' do
#     before(:each) do
#       @server = double :server
#       RSolr.stub :connect => @server
#     end
#   end
# 
#   context 'without connected server' do
#     before(:each) do
#       RSolr.should_receive(:connect).and_raise RuntimeError
#     end
#     it 'should have a nil server' do
#       Query::Solr.new(:some_index_type).server.should == nil
#     end
#   end
# 
# end
