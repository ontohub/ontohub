require 'spec_helper'

describe Project do

  context 'Migrations' do
    %w(name institution homepage description contact).each do |column|
      it { expect(subject).to have_db_column(column).of_type :text }
    end

    it { expect(subject).to have_and_belong_to_many :ontologies }
  end

  context 'Validations' do
    ['http://example.com/', 'https://example.com/', 'file://path/to/file'].each do |val|
      it { expect(subject).to allow_value(val).for :homepage }
    end

    it { expect(subject).to_not allow_value('foo').for :homepage }
  end

end
