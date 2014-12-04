require 'spec_helper'

describe Hets, :needs_hets do

  after do
    File.delete @xml_path if @xml_path
  end

  context 'Output directory parameter' do
    before do
      xml_paths = Hets.parse(ontology_file('owl/pizza'), '/tmp')
      @xml_path = xml_paths.last
    end

    it 'correctly be used' do
      expect(@xml_path.starts_with?('/tmp')).to be(true)
    end
  end

  %w(owl/pizza.owl owl/generations.owl clif/cat.clif).each do |path|
    context path do
      let(:ontology) { create :ontology }
      let(:user) { create :user }

      before do
        xml_paths = Hets.parse(ontology_file(path), '/tmp')
        @xml_path = xml_paths.last
        @pp_path = xml_paths.first
      end

      it 'have created output file' do
        expect(File.exists?(@xml_path)).to be(true)
      end

      it 'have generated importable output' do
        expect { parse_this(user, ontology, @xml_path) }.not_to raise_error
      end
    end
  end

  context 'with access-token' do
    let(:input_file) { ontology_file('clif/cat.clif') }
    let(:access_token) { 'my_access_token' }

    # any_args is a "don't care which and how many arguments" in rspec mocks.
    let(:call_args) { [any_args, "--access_token=#{access_token}", any_args] }
    let(:options) { Hets::Options.new(access_token: access_token) }

    before do
      allow(Subprocess).to receive(:run).with(*call_args).
        and_return('Writing file: some_file')
    end

    it 'have called hets with the access-token' do
      expect(Hets.parse(input_file, '/tmp', options)).to eq(['some_file'])
    end

    it 'created a subprocess with access-token arguments' do
      Hets.parse(input_file, '/tmp', options)
      expect(Subprocess).to(have_received(:run).with(*call_args))
    end
  end

  context 'with url-catalog' do
    let(:input_file) { ontology_file('clif/monoid.clif') }
    let(:url_catalog) do
      ['http://colore.oor.net=http://develop.ontohub.org/colore/ontologies',
      'https://colore.oor.net=https://develop.ontohub.org/colore/ontologies']
    end

    # any_args is a "don't care which and how many arguments" in rspec mocks.
    let(:call_args) { [any_args, '-C', url_catalog.join(','), any_args] }
    let(:options) { Hets::Options.new(url_catalog: url_catalog) }

    before do
      allow(Subprocess).to receive(:run).with(*call_args).
        and_return('Writing file: some_file')
    end

    it 'have called hets with the catalog' do
      expect(Hets.parse(input_file, '/tmp', options)).to eq(['some_file'])
    end

    it 'created a subprocess with catalog arguments' do
      Hets.parse(input_file, '/tmp', options)
      expect(Subprocess).to(have_received(:run).with(*call_args))
    end
  end

  it 'raise exception if provided with wrong file-format' do
    expect { Hets.parse(ontology_file('valid.xml')) }.
      to raise_error(Hets::ExecutionError)
  end

  context 'api-calls' do
    setup_hets

    let(:ontology_iri) { 'http://localhost/ref/1/my_repo/my_ontology' }

    before do
      stub_request(:any, hets_uri)
    end

    context 'with access-token' do
      let(:access_token) { 'my_access_token' }
      let(:options) { Hets::Options.new(access_token: access_token) }

      it 'call hets with the access token in the query string' do
        parse_caller = Hets::ParseCaller.new(HetsInstance.choose, options)
        begin
          parse_caller.call(ontology_iri)
        rescue
        end
        expect(WebMock).
          to have_requested(:get, /\?(.*?;)?access-token=#{access_token}/)
      end
    end

    context 'with url-catalog' do
      let(:url_catalog) do
        ['http://colore.oor.net=http://develop.ontohub.org/colore/ontologies',
        'https://colore.oor.net=https://develop.ontohub.org/colore/ontologies']
      end
      let(:options) { Hets::Options.new(url_catalog: url_catalog) }

      it 'call hets with the url-catalog in the query string' do
        parse_caller = Hets::ParseCaller.new(HetsInstance.choose, options)
        begin
          parse_caller.call(ontology_iri)
        rescue
        end
        expect(WebMock).to have_requested(
          :get, /\?(.*?;)?url-catalog=#{url_catalog.join(',')}/)
      end
    end
  end
end
