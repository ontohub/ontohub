require 'spec_helper'

describe LicenseModel do
  context 'Migrations' do
    %w( name description url ).each do |column|
      it { expect(subject).to have_db_column(column).of_type(:text) }
    end
    it { expect(subject).to have_db_index(:name).unique(true) }
  end

  context 'Validations' do
    context 'when no name is taken' do
      it { expect(subject).to allow_value('foo').for :name }
    end

    context 'when name is already taken' do
      before { LicenseModel.create!(name: 'foo', url: 'http://foo.com') }
      it { expect(subject).to_not allow_value('foo').for :name }
    end

    it 'raise error when LicenseModel without name is to be saved' do
      expect { LicenseModel.create! }.
        to raise_error(ActiveRecord::RecordInvalid)
    end

    context 'URL validator' do
      %w(http://example.com/ https://example.com/ file://path/to/file).
        each do |val|
        it { expect(subject).to allow_value(val).for :url }
      end
    end

    [nil, '', 'fooo'].each do |val|
      it { expect(subject).to_not allow_value(val).for :url }
    end
  end
end
