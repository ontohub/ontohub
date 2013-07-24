# This module imports and exports the logic graph as an rdf ontology.
#
# Author::    Daniel Couto Vale (mailto:danielvale@uni-bremen.de)
# Copyright:: Copyright (c) 2013 Bremen University, SFBTR8
# License::   Distributed as a part of Ontohub.
#
module Logicgraph

  def self.import(pathname)
    importer = nil
    if pathname.nil?
      importer = Importer.new($stdin)
    else
      importer = Importer.new(File.open(pathname, 'r'))
    end
    importer.import()
  end

  def self.export(pathname)
    exporter = nil
    if pathname.nil?
      exporter = Exporter.new($stdout)
    else
      exporter = Exporter.new(File.new(pathname, 'w'))
    end
    exporter.export()
  end

  # A component for importing logic graphs
  class Importer

    def initialize(is)
      @is = is
    end

    def import()
      print @is.read()
    end

  end

  class Exporter
    
    def initialize(os)
      fs = File.new('registry/LogicGraph.empty.owl')
      @document = Nokogiri::XML::Document.parse(fs)
      @os = os
    end

    def export()
      Logic.all.each do |logic|
        declare_individual(fix(logic.iri))
        assert_class("#Logic", fix(logic.iri))
        assert_string_property("#hasName", fix(logic.iri), logic.name)
        assert_string_property("#hasDescription", fix(logic.iri), logic.description)
        assert_object_property("#hasStandardizationStatus", fix(logic.iri), "#" + logic.standardization_status)
        assert_datetimestamp_property("#createdAt", fix(logic.iri), logic.created_at.strftime("%FT%TZ%:z"))
        assert_datetimestamp_property("#updatedAt", fix(logic.iri), logic.updated_at.strftime("%FT%TZ%:z"))
      end
      LogicMapping.all.each do |logic_mapping|
        iri = logic_mapping.iri.gsub(/(.*)(\/)(.*)/, '\1#\3')
        declare_individual(fix(logic_mapping.iri))
        assert_class("#LogicMapping", fix(logic_mapping.iri))
        assert_object_property("#hasSource", fix(logic_mapping.iri), fix(logic_mapping.source.iri))
        assert_object_property("#hasTarget", fix(logic_mapping.iri), fix(logic_mapping.target.iri))
      end
      @os.print(@document)
    end

    def fix(iri)
      return iri.gsub(/(.*)(\/)(.*)/, '\1#\3').gsub("&", "&amp;").gsub("|", "&pipe;")
    end

    def declare_individual(individual_iri)
      individual = @document.create_element("NamedIndividual")
      individual.set_attribute("IRI", individual_iri)
      declaration = @document.create_element("Declaration")
      declaration.add_child(individual)
      root = @document.root()
      root.add_child(declaration)
    end

    def assert_class(class_iri, individual_iri)
      klass = @document.create_element("Class")
      klass.set_attribute("IRI", class_iri)
      individual = @document.create_element("NamedIndividual")
      individual.set_attribute("IRI", individual_iri)
      classAssertion = @document.create_element("ClassAssertion")
      classAssertion.add_child(klass)
      classAssertion.add_child(individual)
      root = @document.root()
      root.add_child(classAssertion)
    end

    def assert_object_property(property_iri, domain_iri, range_iri)
      property = @document.create_element("ObjectProperty")
      property.set_attribute("IRI", property_iri)
      domain = @document.create_element("NamedIndividual")
      domain.set_attribute("IRI", domain_iri)
      range = @document.create_element("NamedIndividual")
      range.set_attribute("IRI", range_iri)
      property_assertion = @document.create_element("ObjectPropertyAssertion")
      property_assertion.add_child(property)
      property_assertion.add_child(domain)
      property_assertion.add_child(range)
      root = @document.root()
      root.add_child(property_assertion)
    end

    def assert_string_property(property_iri, domain_iri, range_text)
      property = @document.create_element("DataProperty")
      property.set_attribute("IRI", property_iri)
      domain = @document.create_element("NamedIndividual")
      domain.set_attribute("IRI", domain_iri)
      range = @document.create_element("Literal")
      range.set_attribute("datatypeIRI", "&xsd;string")
      range_text_node = @document.create_text_node(range_text)
      range.add_child(range_text_node)
      property_assertion = @document.create_element("DataPropertyAssertion")
      property_assertion.add_child(property)
      property_assertion.add_child(domain)
      property_assertion.add_child(range)
      root = @document.root()
      root.add_child(property_assertion)
    end

    def assert_datetimestamp_property(property_iri, domain_iri, range_text)
      property = @document.create_element("DataProperty")
      property.set_attribute("IRI", property_iri)
      domain = @document.create_element("NamedIndividual")
      domain.set_attribute("IRI", domain_iri)
      range = @document.create_element("Literal")
      range.set_attribute("datatypeIRI", "&xsd;dateTimeStamp")
      range_text_node = @document.create_text_node(range_text)
      range.add_child(range_text_node)
      property_assertion = @document.create_element("DataPropertyAssertion")
      property_assertion.add_child(property)
      property_assertion.add_child(domain)
      property_assertion.add_child(range)
      root = @document.root()
      root.add_child(property_assertion)
    end


  end

end
