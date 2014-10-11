require 'spec_helper'

describe Team do
  it { should strip_attribute :name }

  context 'Associations' do
    %i(permissions team_users users).each do |association|
      it { should have_many(association) }
    end
    it { should have_many(:users).through(:team_users) }
  end

  context 'Validations' do
    [ 'foo', '123 4', 'A multiword name' ].each do |val|
      it { should allow_value(val).for :name }
    end

    [ nil, '','   A   ', 'fo','a very tooooooooooooooooooooooooooooooooooooooooooooooo long name' ].each do |val|
      it { should_not allow_value(val).for :name }
    end
  end

  context 'team instance' do
    let(:team) { FactoryGirl.create :team }
    it 'have to_s' do
      expect(team.to_s).to eq(team.name)
    end
  end
end
