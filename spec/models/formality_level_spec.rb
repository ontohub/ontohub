require 'spec_helper'

describe FormalityLevel do
  context 'Migrations' do
    %w( name description ).each do |column|
      it { should have_db_column(column).of_type(:text) }
    end

    it { should have_db_index(:name).unique(true) }
  end

  context 'Validations' do
    context 'when no name is taken' do
      it { should allow_value('foo').for(:name) }
    end

    context "when 'foo' is already taken" do
      before { FormalityLevel.create!(name: 'foo') }

      it { should_not allow_value('foo').for(:name) }
    end

    context 'when FormalityLevel without name is to be saved' do
      it 'raise error' do
        expect { FormalityLevel.create! }.
          to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
