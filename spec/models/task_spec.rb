require 'spec_helper'

describe Task do
  context 'Migrations' do
    it { expect(subject).to have_db_column(:name).of_type(:text) }
    it { expect(subject).to have_db_column(:description).of_type(:text) }
    it { expect(subject).to have_db_index(:name).unique(true) }
  end

  context 'Validations' do
    context 'when no name is taken' do
      it { expect(subject).to allow_value('foo').for :name }
    end

    context 'when name is already taken' do
      before { Task.create!(name: 'foo') }
      it { expect(subject).to_not allow_value('foo').for :name }
    end

    context 'when Task without name is to be saved' do
      it 'raise error' do
        expect { Task.create! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
