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
    "#{Hostname.url_authority}#{locid}"
  end

  def self.parse_via_api(resource, hets_options, structure_only: false)
    mode = structure_only ? :fast_run : :default
    HetsInstance.with_instance! do |hets_instance|
      parse_caller = Hets::ParseCaller.new(hets_instance, hets_options,
                                           resource.repository)
      parse_caller.call(qualified_loc_id_for(resource), with_mode: mode)
    end
  end

  def self.prove_via_api(resource, prove_options)
    HetsInstance.with_instance! do |hets_instance|
      prove_caller = Hets::ProveCaller.new(hets_instance, prove_options,
                                           resource.repository)
      prove_caller.call(qualified_loc_id_for(resource))
    end
  end

  def self.provers_via_api(resource, provers_options)
    HetsInstance.with_instance! do |hets_instance|
      provers_caller = Hets::ProversCaller.new(hets_instance, provers_options,
                                               resource.repository)
      provers_caller.call(qualified_loc_id_for(resource))
    end
  end

  def self.filetype(resource)
    iri = qualified_loc_id_for(resource)
    HetsInstance.with_instance! do |hets_instance|
      filetype_caller = Hets::FiletypeCaller.new(hets_instance)
      response_iri, filetype = filetype_caller.call(iri).split(': ')
    end
    if response_iri == iri
      Mime::Type.lookup(filetype)
    else
      raise FiletypeNotDeterminedError.new("#{response_iri}: #{filetype}")
    end
  end
end
