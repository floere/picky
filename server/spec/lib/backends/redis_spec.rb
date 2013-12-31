require 'spec_helper'

describe Picky::Backends::Redis do

  # context 'with options' do
  #   before(:each) do
  #     @backend = described_class.new inverted:      Picky::Backends::Redis::Float.new(:unimportant, :unimportant),
  #                                    weights:       Picky::Backends::Redis::String.new(:unimportant, :unimportant),
  #                                    similarity:    Picky::Backends::Redis::Float.new(:unimportant, :unimportant),
  #                                    configuration: Picky::Backends::Redis::List.new(:unimportant, :unimportant)
  #
  #     @backend.stub :timed_exclaim
  #   end
  #
  #   describe "redis_with_scripting?" do
  #     let(:client) { double :client}
  #     let(:redis) { described_class.new client: client }
  #
  #     it "answers correctly" do
  #       client.stub :info => {"redis_version"=>"2.2.2", "redis_git_sha1"=>"00000000", "redis_git_dirty"=>"0", "arch_bits"=>"64", "multiplexing_api"=>"kqueue", "process_id"=>"70364", "uptime_in_seconds"=>"86804", "uptime_in_days"=>"1", "lru_clock"=>"2057342", "used_cpu_sys"=>"12.76", "used_cpu_user"=>"13.44", "used_cpu_sys_childrens"=>"0.62", "used_cpu_user_childrens"=>"0.30", "connected_clients"=>"1", "connected_slaves"=>"0", "client_longest_output_list"=>"0", "client_biggest_input_buf"=>"0", "blocked_clients"=>"0", "used_memory"=>"34389632", "used_memory_human"=>"32.80M", "used_memory_rss"=>"675840", "mem_fragmentation_ratio"=>"0.02", "use_tcmalloc"=>"0", "loading"=>"0", "aof_enabled"=>"0", "changes_since_last_save"=>"0", "bgsave_in_progress"=>"0", "last_save_time"=>"1320721195", "bgrewriteaof_in_progress"=>"0", "total_connections_received"=>"20", "total_commands_processed"=>"327594", "expired_keys"=>"0", "evicted_keys"=>"0", "keyspace_hits"=>"218584", "keyspace_misses"=>"98664", "hash_max_zipmap_entries"=>"512", "hash_max_zipmap_value"=>"64", "pubsub_channels"=>"0", "pubsub_patterns"=>"0", "vm_enabled"=>"0", "role"=>"master", "allocation_stats"=>"2=74,6=1,8=15,9=156,10=142939,11=104891,12=290902,13=263791,14=14570,15=29143,16=1661979,17=8986,18=6370,19=4508,20=18010,21=1622,22=1136,23=544,24=419271,25=154,26=73,27=32,28=30,29=14,32=419046,33=6,34=7,35=15,36=10,37=12,38=625,39=7127,40=207716,41=40840,42=7246,43=2645,44=28390,45=37835,46=35164,47=67465,48=54765,49=41247,50=44391,51=36420,52=29582,53=21491,54=18575,55=14101,56=61954,57=5476,58=3246,59=2227,60=1502,61=868,62=541,63=282,64=69006,65=87,66=58,67=32,68=30,69=6,70=2,71=5,72=12723,74=19,75=2,76=13,77=6,80=12500,81=10,82=4,83=8,84=10,85=14,86=5,87=37,88=97714,89=58,91=30,93=68,94=14,95=35,97=56,99=46,101=24,103=17,104=846,105=1,106=15,107=19,109=4,110=6,111=13,113=8,114=8,115=4,116=5,117=8,118=11,119=4,120=217,121=18,122=6,125=5,126=12,128=4411,131=12,133=8,136=57,137=14,138=10,142=6,143=4,145=6,147=14,150=4,152=23,153=6,157=4,158=6,159=14,163=8,164=18,166=4,168=6,169=1,170=16,171=27,173=7,174=10,175=31,177=14,178=6,179=13,181=39,182=4,183=12,184=7,185=42,187=16,189=69,191=22,193=17,195=8,196=16,197=23,199=20,201=23,203=12,205=4,206=16,207=6,208=4,209=10,211=1,213=8,215=4,216=10,217=4,218=14,219=10,221=14,223=4,225=8,226=6,227=4,228=10,230=10,232=6,234=6,237=4,238=6,239=8,240=6,241=4,242=6,245=6,248=4,249=16,250=6,252=4,253=4,>=256=113463", "db15"=>"keys=26605,expires=0"}
  #
  #       redis.redis_with_scripting?.should == false
  #     end
  #     it "answers correctly" do
  #       client.stub :info => {"redis_version"=>"2.6.0", "redis_git_sha1"=>"00000000", "redis_git_dirty"=>"0", "arch_bits"=>"64", "multiplexing_api"=>"kqueue", "process_id"=>"70364", "uptime_in_seconds"=>"86804", "uptime_in_days"=>"1", "lru_clock"=>"2057342", "used_cpu_sys"=>"12.76", "used_cpu_user"=>"13.44", "used_cpu_sys_childrens"=>"0.62", "used_cpu_user_childrens"=>"0.30", "connected_clients"=>"1", "connected_slaves"=>"0", "client_longest_output_list"=>"0", "client_biggest_input_buf"=>"0", "blocked_clients"=>"0", "used_memory"=>"34389632", "used_memory_human"=>"32.80M", "used_memory_rss"=>"675840", "mem_fragmentation_ratio"=>"0.02", "use_tcmalloc"=>"0", "loading"=>"0", "aof_enabled"=>"0", "changes_since_last_save"=>"0", "bgsave_in_progress"=>"0", "last_save_time"=>"1320721195", "bgrewriteaof_in_progress"=>"0", "total_connections_received"=>"20", "total_commands_processed"=>"327594", "expired_keys"=>"0", "evicted_keys"=>"0", "keyspace_hits"=>"218584", "keyspace_misses"=>"98664", "hash_max_zipmap_entries"=>"512", "hash_max_zipmap_value"=>"64", "pubsub_channels"=>"0", "pubsub_patterns"=>"0", "vm_enabled"=>"0", "role"=>"master", "allocation_stats"=>"2=74,6=1,8=15,9=156,10=142939,11=104891,12=290902,13=263791,14=14570,15=29143,16=1661979,17=8986,18=6370,19=4508,20=18010,21=1622,22=1136,23=544,24=419271,25=154,26=73,27=32,28=30,29=14,32=419046,33=6,34=7,35=15,36=10,37=12,38=625,39=7127,40=207716,41=40840,42=7246,43=2645,44=28390,45=37835,46=35164,47=67465,48=54765,49=41247,50=44391,51=36420,52=29582,53=21491,54=18575,55=14101,56=61954,57=5476,58=3246,59=2227,60=1502,61=868,62=541,63=282,64=69006,65=87,66=58,67=32,68=30,69=6,70=2,71=5,72=12723,74=19,75=2,76=13,77=6,80=12500,81=10,82=4,83=8,84=10,85=14,86=5,87=37,88=97714,89=58,91=30,93=68,94=14,95=35,97=56,99=46,101=24,103=17,104=846,105=1,106=15,107=19,109=4,110=6,111=13,113=8,114=8,115=4,116=5,117=8,118=11,119=4,120=217,121=18,122=6,125=5,126=12,128=4411,131=12,133=8,136=57,137=14,138=10,142=6,143=4,145=6,147=14,150=4,152=23,153=6,157=4,158=6,159=14,163=8,164=18,166=4,168=6,169=1,170=16,171=27,173=7,174=10,175=31,177=14,178=6,179=13,181=39,182=4,183=12,184=7,185=42,187=16,189=69,191=22,193=17,195=8,196=16,197=23,199=20,201=23,203=12,205=4,206=16,207=6,208=4,209=10,211=1,213=8,215=4,216=10,217=4,218=14,219=10,221=14,223=4,225=8,226=6,227=4,228=10,230=10,232=6,234=6,237=4,238=6,239=8,240=6,241=4,242=6,245=6,248=4,249=16,250=6,252=4,253=4,>=256=113463", "db15"=>"keys=26605,expires=0"}
  #
  #       redis.redis_with_scripting?.should == true
  #     end
  #     it "answers correctly" do
  #       client.stub :info => {:redis_version=>"2.2.2", "redis_git_sha1"=>"00000000", "redis_git_dirty"=>"0", "arch_bits"=>"64", "multiplexing_api"=>"kqueue", "process_id"=>"70364", "uptime_in_seconds"=>"86804", "uptime_in_days"=>"1", "lru_clock"=>"2057342", "used_cpu_sys"=>"12.76", "used_cpu_user"=>"13.44", "used_cpu_sys_childrens"=>"0.62", "used_cpu_user_childrens"=>"0.30", "connected_clients"=>"1", "connected_slaves"=>"0", "client_longest_output_list"=>"0", "client_biggest_input_buf"=>"0", "blocked_clients"=>"0", "used_memory"=>"34389632", "used_memory_human"=>"32.80M", "used_memory_rss"=>"675840", "mem_fragmentation_ratio"=>"0.02", "use_tcmalloc"=>"0", "loading"=>"0", "aof_enabled"=>"0", "changes_since_last_save"=>"0", "bgsave_in_progress"=>"0", "last_save_time"=>"1320721195", "bgrewriteaof_in_progress"=>"0", "total_connections_received"=>"20", "total_commands_processed"=>"327594", "expired_keys"=>"0", "evicted_keys"=>"0", "keyspace_hits"=>"218584", "keyspace_misses"=>"98664", "hash_max_zipmap_entries"=>"512", "hash_max_zipmap_value"=>"64", "pubsub_channels"=>"0", "pubsub_patterns"=>"0", "vm_enabled"=>"0", "role"=>"master", "allocation_stats"=>"2=74,6=1,8=15,9=156,10=142939,11=104891,12=290902,13=263791,14=14570,15=29143,16=1661979,17=8986,18=6370,19=4508,20=18010,21=1622,22=1136,23=544,24=419271,25=154,26=73,27=32,28=30,29=14,32=419046,33=6,34=7,35=15,36=10,37=12,38=625,39=7127,40=207716,41=40840,42=7246,43=2645,44=28390,45=37835,46=35164,47=67465,48=54765,49=41247,50=44391,51=36420,52=29582,53=21491,54=18575,55=14101,56=61954,57=5476,58=3246,59=2227,60=1502,61=868,62=541,63=282,64=69006,65=87,66=58,67=32,68=30,69=6,70=2,71=5,72=12723,74=19,75=2,76=13,77=6,80=12500,81=10,82=4,83=8,84=10,85=14,86=5,87=37,88=97714,89=58,91=30,93=68,94=14,95=35,97=56,99=46,101=24,103=17,104=846,105=1,106=15,107=19,109=4,110=6,111=13,113=8,114=8,115=4,116=5,117=8,118=11,119=4,120=217,121=18,122=6,125=5,126=12,128=4411,131=12,133=8,136=57,137=14,138=10,142=6,143=4,145=6,147=14,150=4,152=23,153=6,157=4,158=6,159=14,163=8,164=18,166=4,168=6,169=1,170=16,171=27,173=7,174=10,175=31,177=14,178=6,179=13,181=39,182=4,183=12,184=7,185=42,187=16,189=69,191=22,193=17,195=8,196=16,197=23,199=20,201=23,203=12,205=4,206=16,207=6,208=4,209=10,211=1,213=8,215=4,216=10,217=4,218=14,219=10,221=14,223=4,225=8,226=6,227=4,228=10,230=10,232=6,234=6,237=4,238=6,239=8,240=6,241=4,242=6,245=6,248=4,249=16,250=6,252=4,253=4,>=256=113463", "db15"=>"keys=26605,expires=0"}
  #
  #       redis.redis_with_scripting?.should == false
  #     end
  #     it "answers correctly" do
  #       client.stub :info => {:redis_version=>"2.6.0", "redis_git_sha1"=>"00000000", "redis_git_dirty"=>"0", "arch_bits"=>"64", "multiplexing_api"=>"kqueue", "process_id"=>"70364", "uptime_in_seconds"=>"86804", "uptime_in_days"=>"1", "lru_clock"=>"2057342", "used_cpu_sys"=>"12.76", "used_cpu_user"=>"13.44", "used_cpu_sys_childrens"=>"0.62", "used_cpu_user_childrens"=>"0.30", "connected_clients"=>"1", "connected_slaves"=>"0", "client_longest_output_list"=>"0", "client_biggest_input_buf"=>"0", "blocked_clients"=>"0", "used_memory"=>"34389632", "used_memory_human"=>"32.80M", "used_memory_rss"=>"675840", "mem_fragmentation_ratio"=>"0.02", "use_tcmalloc"=>"0", "loading"=>"0", "aof_enabled"=>"0", "changes_since_last_save"=>"0", "bgsave_in_progress"=>"0", "last_save_time"=>"1320721195", "bgrewriteaof_in_progress"=>"0", "total_connections_received"=>"20", "total_commands_processed"=>"327594", "expired_keys"=>"0", "evicted_keys"=>"0", "keyspace_hits"=>"218584", "keyspace_misses"=>"98664", "hash_max_zipmap_entries"=>"512", "hash_max_zipmap_value"=>"64", "pubsub_channels"=>"0", "pubsub_patterns"=>"0", "vm_enabled"=>"0", "role"=>"master", "allocation_stats"=>"2=74,6=1,8=15,9=156,10=142939,11=104891,12=290902,13=263791,14=14570,15=29143,16=1661979,17=8986,18=6370,19=4508,20=18010,21=1622,22=1136,23=544,24=419271,25=154,26=73,27=32,28=30,29=14,32=419046,33=6,34=7,35=15,36=10,37=12,38=625,39=7127,40=207716,41=40840,42=7246,43=2645,44=28390,45=37835,46=35164,47=67465,48=54765,49=41247,50=44391,51=36420,52=29582,53=21491,54=18575,55=14101,56=61954,57=5476,58=3246,59=2227,60=1502,61=868,62=541,63=282,64=69006,65=87,66=58,67=32,68=30,69=6,70=2,71=5,72=12723,74=19,75=2,76=13,77=6,80=12500,81=10,82=4,83=8,84=10,85=14,86=5,87=37,88=97714,89=58,91=30,93=68,94=14,95=35,97=56,99=46,101=24,103=17,104=846,105=1,106=15,107=19,109=4,110=6,111=13,113=8,114=8,115=4,116=5,117=8,118=11,119=4,120=217,121=18,122=6,125=5,126=12,128=4411,131=12,133=8,136=57,137=14,138=10,142=6,143=4,145=6,147=14,150=4,152=23,153=6,157=4,158=6,159=14,163=8,164=18,166=4,168=6,169=1,170=16,171=27,173=7,174=10,175=31,177=14,178=6,179=13,181=39,182=4,183=12,184=7,185=42,187=16,189=69,191=22,193=17,195=8,196=16,197=23,199=20,201=23,203=12,205=4,206=16,207=6,208=4,209=10,211=1,213=8,215=4,216=10,217=4,218=14,219=10,221=14,223=4,225=8,226=6,227=4,228=10,230=10,232=6,234=6,237=4,238=6,239=8,240=6,241=4,242=6,245=6,248=4,249=16,250=6,252=4,253=4,>=256=113463", "db15"=>"keys=26605,expires=0"}
  #
  #       redis.redis_with_scripting?.should == true
  #     end
  #   end
  #
  #   describe 'create_...' do
  #     [
  #       [:inverted,      Picky::Backends::Redis::Float],
  #       [:weights,       Picky::Backends::Redis::String],
  #       [:similarity,    Picky::Backends::Redis::Float],
  #       [:configuration, Picky::Backends::Redis::List]
  #     ].each do |type, kind|
  #       it "creates and returns a(n) #{type} index" do
  #         @backend.send(:"create_#{type}",
  #                       stub(type, :identifier => "some_identifier:#{type}")
  #         ).should be_kind_of(kind)
  #       end
  #     end
  #   end
  # end

  # context 'with lambda options' do
  #   before(:each) do
  #     @backend = described_class.new inverted:      ->(bundle, client){ Picky::Backends::Redis::Float.new(client, bundle.identifier(:inverted)) },
  #                                    weights:       ->(bundle, client){ Picky::Backends::Redis::String.new(client, bundle.identifier(:weights)) },
  #                                    similarity:    ->(bundle, client){ Picky::Backends::Redis::Float.new(client, bundle.identifier(:similarity)) },
  #                                    configuration: ->(bundle, client){ Picky::Backends::Redis::List.new(client, bundle.identifier(:configuration)) }
  #
  #     @backend.stub :timed_exclaim
  #   end
  #
  #   describe 'create_...' do
  #     [
  #       [:inverted,      Picky::Backends::Redis::Float],
  #       [:weights,       Picky::Backends::Redis::String],
  #       [:similarity,    Picky::Backends::Redis::Float],
  #       [:configuration, Picky::Backends::Redis::List]
  #     ].each do |type, kind|
  #       it "creates and returns a(n) #{type} index" do
  #         to_a_able_double = Object.new
  #         to_a_able_stub.stub :identifier => "some_identifier:#{type}"
  #         @backend.send(:"create_#{type}", to_a_able_stub).should be_kind_of(kind)
  #       end
  #     end
  #   end
  # end

  context 'without options' do
    before(:each) do
      @backend = described_class.new

      @backend.stub :timed_exclaim
    end

    describe 'create_...' do
      [
        [:inverted,      Picky::Backends::Redis::List],
        [:weights,       Picky::Backends::Redis::Float],
        [:similarity,    Picky::Backends::Redis::List],
        [:configuration, Picky::Backends::Redis::String]
      ].each do |type, kind|
        it "creates and returns a(n) #{type} index" do
          @backend.send(:"create_#{type}",
                        stub(type, :identifier => "some_identifier:#{type}")
          ).should be_kind_of(kind)
        end
      end
    end

    # TODO
    #
    # describe "ids" do
    #   before(:each) do
    #     @combination1 = double :combination1
    #     @combination2 = double :combination2
    #     @combination3 = double :combination3
    #     @combinations = [@combination1, @combination2, @combination3]
    #   end
    #   it "should intersect correctly" do
    #     @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
    #     @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
    #     @combination3.should_receive(:ids).once.with.and_return (1..10).to_a
    #
    #     @backend.ids(@combinations, :any, :thing).should == (1..10).to_a
    #   end
    #   it "should intersect symbol_keys correctly" do
    #     @combination1.should_receive(:ids).once.with.and_return (:'00001'..:'10000').to_a
    #     @combination2.should_receive(:ids).once.with.and_return (:'00001'..:'00100').to_a
    #     @combination3.should_receive(:ids).once.with.and_return (:'00001'..:'00010').to_a
    #
    #     @backend.ids(@combinations, :any, :thing).should == (:'00001'..:'0010').to_a
    #   end
    #   it "should intersect correctly when intermediate intersect result is empty" do
    #     @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
    #     @combination2.should_receive(:ids).once.with.and_return (11..100).to_a
    #     @combination3.should_receive(:ids).once.with.and_return (1..10).to_a
    #
    #     @backend.ids(@combinations, :any, :thing).should == []
    #   end
    #   it "should be fast" do
    #     @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
    #     @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
    #     @combination3.should_receive(:ids).once.with.and_return (1..10).to_a
    #
    #     performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.004
    #   end
    #   it "should be fast" do
    #     @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
    #     @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
    #     @combination3.should_receive(:ids).once.with.and_return (1..10).to_a
    #
    #     performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.00015
    #   end
    #   it "should be fast" do
    #     @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
    #     @combination2.should_receive(:ids).once.with.and_return (901..1000).to_a
    #     @combination3.should_receive(:ids).once.with.and_return (1..10).to_a
    #
    #     performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.0001
    #   end
    # end
  end

end