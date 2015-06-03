require 'spec_helper'

describe Autocomplete do
  def autocomplete(scopes, query)
    ac = Autocomplete.new
    scopes.split(',').each { |s| ac.add_scope(s) }
    result = ac.search(query)
  end

  context 'for users and teams' do
    let!(:foo) { create :user, name: 'foo' }
    let!(:foobar) { create :user, name: 'foobar' }
    let!(:team_bars) { create :team, name: 'special bars' }
    let!(:team_faker) { create :team, name: 'faker' }

    before do
      # should never be found
      create :user, name: 'xxyyzz'
      create :team, name: 'aabbbccc'
    end

    context 'searching for user' do
      # two results
      context 'foo' do
        it 'find two users' do
          expect(autocomplete('User', foo.name).size).to eq(2)
        end
      end

      # one result
      context 'foobar' do
        context 'by name' do
          it 'find the user' do
            expect(autocomplete('User', foobar.name)).to eq([foobar])
          end
        end

        context 'by email' do
          it 'find the user' do
            expect(autocomplete('User', foobar.email)).to eq([foobar])
          end
        end
      end

      # no results
      context 'baz' do
        it 'not found any users' do
          expect(autocomplete('User', 'baz').size).to eq(0)
        end
      end
    end

    context 'searching user and team' do
      # 1 user + 1 team
      context 'bar' do
        let(:result) { autocomplete('User,Team', 'bar') }

        it 'get two results' do
          expect(result.size).to eq(2)
        end

        it 'find the user' do
          expect(result).to include(foobar)
        end

        it 'find the team' do
          expect(result).to include(team_bars)
        end
      end

      # 1 team
      context 'faker' do
        it 'find the team' do
          expect(autocomplete('User,Team', team_faker.name)).
            to include(team_faker)
        end
      end
    end

  end

  context 'autocomplete with exclusion' do
    let(:users) { 5.times.map{|i| create :user, name: "foo#{i}" } }
    let(:result) do
      ac = Autocomplete.new
      ac.add_scope('User', users.shift(2).map(&:id))
      ac.search('foo')
    end

    it 'only find 3 users' do
      expect(result.count).to eq(3)
    end
  end
end
