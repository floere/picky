module Solr
  class SchemaGenerator

    attr_reader :types

    # Takes an array of index type configs.
    #
    def initialize configuration
      @types = configuration.types
    end

    #
    #
    def generate
      generate_schema_for bound_field_names
    end

    # Returns a binding with the values needed for the schema xml.
    #
    def bound_field_names
      field_names = combine_field_names
      binding
    end

    # TODO
    #
    def combine_field_names
      field_names = []
      types.each do |type|
        field_names += type.solr_fields.map(&:name)
      end
      field_names.uniq!
      field_names
    end

    #
    #
    def generate_schema_for binding
      template_text = read_template
      result = evaluate_erb template_text, binding
      write result
    end

    #
    #
    def evaluate_erb text, binding
      require 'erb'
      template = ERB.new text
      template.result binding
    end

    #
    #
    def read_template
      template_path = File.join PICKY_ROOT, 'solr', 'conf', 'schema.xml.erb'
      schema = ''
      File.open(template_path, 'r') do |f|
        schema = f.read
      end
      schema
    end

    #
    #
    def write result
      schema_path = File.join PICKY_ROOT, 'solr', 'conf', 'schema.xml'
      File.open(schema_path, 'w') do |f|
        f << result
      end
    end

  end
end