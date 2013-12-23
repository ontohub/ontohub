require 'spec_helper'

describe Project do

  context 'Migrations' do
    %w(name institution homepage description contact).each do |column|
      it { should have_db_column(column).of_type :string }
    end

    it { should have_and_belong_to_many :ontologies }
  end
    
  context 'Validations' do
    ['http://example.com/', 'https://example.com/', 'file://path/to/file'].each do |val|
      it { should allow_value(val).for :homepage }
    end

    it { should_not allow_value('foo').for :homepage }
  end

end
