# This module imports and exports the logic graph as an owl ontology.
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
      @os = os
    end

    def export()
      @os.print("Blablabla\n")
    end
  end

end
