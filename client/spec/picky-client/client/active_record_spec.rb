require 'spec_helper'

describe Picky::Client::ActiveRecord do
  
  let(:fake_ar) do
    Class.new do
      
      attr_reader :id, :name, :surname
      
      def initialize id, name, surname
        @id, @name, @surname = id, name, surname
      end
      
      class << self
        
        attr_accessor :after_commits
        
        def after_commit &block
          self.after_commits ||= []
          self.after_commits << block
        end
        
        def table_name
          'some_index_name'
        end
        
      end
      
      def attributes
        { 'id' => nil, 'name' => nil, 'surname' => nil }
      end

      def virtual_attribute
        'virtual'
      end
      
      def save
        after_commit
      end
      
      def destroy
        @destroyed = true
        after_commit
      end
      
      def destroyed?
        @destroyed
      end
      
      def after_commit
        self.class.after_commits.each do |block|
          block.call self
        end
      end
      
    end
  end
  
  it 'is a module' do
    described_class.should be_kind_of(Module)
  end
  
  context 'default module' do
    let(:ar_module) { described_class.configure }
    
    it 'is (also) a module' do
      ar_module.should be_kind_of(Module)
    end
  end
  
  # describe 'directly extend' do
  #   let(:ar) { fake_ar.extend(described_class) }
  #   
  #   it 'calls the right method in the client' do
  #     ar.save
  #   end
  #     
  #   it 'calls the right method in the client' do
  #     ar.destroy
  #   end
  #   
  # end
  
  context 'with params' do
    let(:client) { stub :client }
    context 'with client' do
      let(:ar_module) { described_class.configure :client => client }
      let(:ar) { fake_ar.extend(ar_module).new(1, 'Niko', 'Dittmann') }
    
      it 'is a module' do
        ar_module.should be_kind_of(Module)
      end
    
      it 'calls the right method in the client' do
        client.should_receive(:replace).once.with 'some_index_name', { 'id' => 1, 'name' => 'Niko', 'surname' => 'Dittmann' }
      
        ar.save
      end
      
      it 'calls the right method in the client' do
        client.should_receive(:remove).once.with 'some_index_name', { 'id' => 1 }
        
        ar.destroy
      end
      
    end
    
    context 'with client and index' do
      let(:ar_module) { described_class.configure :client => client, :index => 'some_other_index_name' }
      let(:ar) { fake_ar.extend(ar_module).new(1, 'Niko', 'Dittmann') }
    
      it 'is a module' do
        ar_module.should be_kind_of(Module)
      end
    
      it 'calls the right method in the client' do
        client.should_receive(:replace).once.with 'some_other_index_name', { 'id' => 1, 'name' => 'Niko', 'surname' => 'Dittmann' }
      
        ar.save
      end
      
      it 'calls the right method in the client' do
        client.should_receive(:remove).once.with 'some_other_index_name', { 'id' => 1 }
        
        ar.destroy
      end
    end
    context 'with client and specific attributes' do
      let(:ar_module) { described_class.configure 'name', :client => client }
      let(:ar) { fake_ar.extend(ar_module).new(1, 'Niko', 'Dittmann') }
    
      it 'is a module' do
        ar_module.should be_kind_of(Module)
      end
    
      it 'calls the right method in the client' do
        client.should_receive(:replace).once.with 'some_index_name', { 'id' => 1, 'name' => 'Niko' }
      
        ar.save
      end
      
      it 'calls the right method in the client' do
        client.should_receive(:remove).once.with 'some_index_name', { 'id' => 1 }
        
        ar.destroy
      end
    end
    context 'with client and virtual attributes' do
      let(:ar_module) { described_class.configure :client => client, :virtuals => ['virtual_attribute'] }
      let(:ar) { fake_ar.extend(ar_module).new(1, 'Niko', 'Dittmann') }
    
      it 'is a module' do
        ar_module.should be_kind_of(Module)
      end
    
      it 'calls the right method in the client' do
        client.should_receive(:replace).once.with 'some_index_name', { 'id' => 1, 'name' => 'Niko', 'surname' => 'Dittmann', 'virtual_attribute' => 'virtual' }
      
        ar.save
      end
      
      it 'calls the right method in the client' do
        client.should_receive(:remove).once.with 'some_index_name', { 'id' => 1 }
        
        ar.destroy
      end
    end
    context 'standard client' do
      it 'instantiates the client correctly' do
        Picky::Client.should_receive(:new).once.with :path => '/'
        
        described_class.configure
      end
      it 'instantiates the client correctly' do
        Picky::Client.should_receive(:new).once.with :host => 'some_host', :port => :some_port, :path => '/bla'
        
        described_class.configure :host => 'some_host', :port => :some_port, :path => '/bla'
      end
    end
  end
  
end
