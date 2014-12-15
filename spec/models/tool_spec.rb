require 'spec_helper'

describe Tool do
  context 'Migrations' do
    %w( name description url ).each do |column|
      it { should have_db_column(column).of_type(:text) }
    end
    it { should have_db_index(:name).unique(true) }
  end

  context 'Validations' do
    ['http://example.com/', 'https://example.com/', 'file://path/to/file'].
      each do |val|
      it { should allow_value(val).for :url }
    end

    [nil, '', 'fooo'].each do |val|
      it { should_not allow_value(val).for :url }
    end
  end
end
