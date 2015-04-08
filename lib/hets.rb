require 'date'

module Hets
  include Errors

  def self.minimal_version_string
    "v#{minimum_version}, #{minimum_revision}"
  end

  def self.minimum_revision
    Settings.hets.version_minimum_revision
  end

  def self.minimum_version
    Settings.hets.version_minimum_version
  end

  def self.qualified_loc_id_for(resource)
    locid = URI.escape(resource.versioned_locid)
    "http://#{Ontohub::Application.config.fqdn}#{locid}"
  end

  def self.parse_via_api(resource, hets_options, structure_only: false)
    mode = structure_only ? :fast_run : :default
    parse_caller = Hets::ParseCaller.new(HetsInstance.choose!, hets_options)
    parse_caller.call(qualified_loc_id_for(resource), with_mode: mode)
  end

  def self.prove_via_api(resource, prove_options)
    prove_caller = Hets::ProveCaller.new(HetsInstance.choose!, prove_options)
    prove_caller.call(qualified_loc_id_for(resource))
  end

  def self.provers_via_api(resource, provers_options)
    provers_caller = Hets::ProversCaller.new(HetsInstance.choose!, provers_options)
    provers_caller.call(qualified_loc_id_for(resource))
  end

  def self.filetype(resource)
    iri = qualified_loc_id_for(resource)
    filetype_caller = Hets::FiletypeCaller.new(HetsInstance.choose!)

    response_iri, filetype = filetype_caller.call(iri).split(': ')
    if response_iri == iri
      Mime::Type.lookup(filetype)
    else
      raise FiletypeNotDeterminedError.new("#{response_iri}: #{filetype}")
    end
  end
end
