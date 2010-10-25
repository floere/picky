require 'spec_helper'
describe Configuration::Field do
  
  context "unit specs" do
    describe "source" do
      context "with source" do
        before(:each) do
          @field = Configuration::Field.new :some_name, :source => :some_given_source

          @type = stub :type, :name => :some_type
          @field.type = @type
        end
        it "returns the given source" do
          @field.source.should == :some_given_source
        end
      end
      context "without source" do
        before(:each) do
          @field = Configuration::Field.new :some_name

          @type = stub :type, :name => :some_type, :source => :some_type_source
          @field.type = @type
        end
        it "returns the type's source" do
          @field.source.should == :some_type_source
        end
      end
    end
    context "name symbol" do
      before(:each) do
        @field = Configuration::Field.new :some_name
        
        @type = stub :type, :name => :some_type
        @field.type = @type
      end
      describe "search_index_file_name" do
        it "returns the right file name" do
          @field.search_index_file_name.should == 'some/search/root/index/test/some_type/prepared_some_name_index.txt'
        end
      end
      describe "generate_qualifiers_from" do
        context "with qualifiers" do
          it "uses the qualifiers" do
            @field.generate_qualifiers_from(:qualifiers => :some_qualifiers).should == :some_qualifiers
          end
        end
        context "without qualifiers" do
          context "with qualifier" do
            it "uses the [qualifier]" do
              @field.generate_qualifiers_from(:qualifier => :some_qualifier).should == [:some_qualifier]
            end
          end
          context "without qualifier" do
            context "with name" do
              it "uses the [name]" do
                @field.generate_qualifiers_from(:nork => :blark).should == [:some_name]
              end
            end
          end
        end
      end
    end
    context "name string" do
      before(:each) do
        @field = Configuration::Field.new 'some_name'
      end
      describe "generate_qualifiers_from" do
        context "without qualifiers" do
          context "without qualifier" do
            context "with name" do
              it "uses the [name]" do
                @field.generate_qualifiers_from(:nork => :blark).should == [:some_name]
              end
            end
          end
        end
      end
    end
  end
  
end