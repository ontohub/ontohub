require 'spec_helper'

describe LogicgraphParser do
  def open_fixture(name)
    File.open(fixture_file(name))
  end

  context "LogicgraphParser" do
    context 'parsing empty XML' do
      let(:symbols) { [] }
      before do
        OntologyParser.parse open_fixture('empty.xml'),
          symbol: Proc.new{ |h| symbols << h }
      end

      it 'not find any symbol' do
        expect(symbols.count).to eq(0)
      end
    end

    context 'parsing invalid XML' do
      it 'not throw an exception' do
        expect(OntologyParser.parse open_fixture('broken.xml'), {}).
          not_to raise_error
      end
    end

  end

end
