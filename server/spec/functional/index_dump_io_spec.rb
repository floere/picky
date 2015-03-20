# encoding: utf-8
#
require 'spec_helper'

describe 'Index#dump(io)' do
  
  it 'gets faster' do
    index = Picky::Index.new :dump_with_io do
      category :text, similarity: Picky::Similarity::DoubleMetaphone.new
    end

    thing = Struct.new :id, :text
    index.add thing.new(1, 'this will be dumped')

    exact_inverted = StringIO.new
    exact_weights = StringIO.new
    exact_similarity = StringIO.new
    
    partial_inverted = StringIO.new
    partial_weights = StringIO.new
    partial_similarity = StringIO.new
    
    io_hash = {
      exact: {
        inverted: exact_inverted,
        weights: exact_weights,
        similarity: exact_similarity
      },
      partial: {
        inverted: partial_inverted,
        weights: partial_weights,
        similarity: partial_similarity
      }
    }

    index.dump io_hash
    
    exact_inverted.string.should == '{"this":[1],"will":[1],"be":[1],"dumped":[1]}'
    partial_inverted.string.should == '{"this":[1],"thi":[1],"th":[1],"will":[1],"wil":[1],"wi":[1],"be":[1],"b":[1],"dumped":[1],"dumpe":[1],"dump":[1]}'
    
    exact_weights.string.should == '{"this":0.0,"will":0.0,"be":0.0,"dumped":0.0}'
    partial_weights.string.should == '{"this":0.0,"thi":0.0,"th":0.0,"will":0.0,"wil":0.0,"wi":0.0,"be":0.0,"b":0.0,"dumped":0.0,"dumpe":0.0,"dump":0.0}'
    
    exact_similarity.string.should == "\x04\b{\tI\"\a0S\x06:\x06EF[\x06I\"\tthis\x06;\x00TI\"\aAL\x06;\x00F[\x06I\"\twill\x06;\x00TI\"\x06P\x06;\x00F[\x06I\"\abe\x06;\x00TI\"\tTMPT\x06;\x00F[\x06I\"\vdumped\x06;\x00T"
    partial_similarity.string.should == '' # Always empty.
  end
  
end