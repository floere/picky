require 'spec_helper'

describe Picky do

  it 'sets the right external encoding' do
    Encoding.default_external.should == Encoding::UTF_8
  end
  # THINK What to set default internal encoding to?
  #
  it 'sets the right internal encoding' do
    Encoding.default_internal.should be_nil
  end
  
  it 'loads in a simple ruby environment with the defined requirements' do
    # TODO Picky.root is set to /spec/temp in spec_helper, so is this the "best" way?
    load_path   = File.expand_path('../../lib', __dir__)
    ruby        = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')
    
    simple_load = <<-COMMAND
      #{ruby} -I #{load_path} -r picky -e "puts 'OK'"
    COMMAND

    response = IO.popen(simple_load, err: [:child, :out])
    expect(response.readlines.last.chomp).to eq 'OK'
  end
  
end