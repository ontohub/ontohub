require 'spec_helper'

describe Task do
  context 'Migrations' do
    it { should have_db_column(:name).of_type(:text) }
    it { should have_db_column(:description).of_type(:text) }
    it { should have_db_index(:name).unique(true) }
  end

  context 'Validations' do
    context 'when no name is taken' do
      it { should allow_value('foo').for :name }
    end

    context 'when name is already taken' do
      before { Task.create!(name: 'foo') }
      it { should_not allow_value('foo').for :name }
    end

    context 'when Task without name is to be saved' do
      it 'raise error' do
        expect { Task.create! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
