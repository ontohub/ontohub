require 'spec_helper'

describe 'Repository Access' do
  context 'fetching repositories' do
    let(:user)                { FactoryGirl.create :user }
    let!(:repository_pub_r)   { FactoryGirl.create :repository, user: user,
      access: 'public_r' }
    let!(:repository_pub_rw)  { FactoryGirl.create :repository, user: user,
      access: 'public_rw' }
    let!(:repository_priv_r)  { FactoryGirl.create :repository, user: user,
      access: 'private_r' }
    let!(:repository_priv_rw) { FactoryGirl.create :repository, user: user,
      access: 'private_rw' }

    %w(_r _rw).each do |access_modifier|
      it "should fetch the public#{access_modifier} repository" do
        expect(Repository.pub.map(&:access).
          include?("public#{access_modifier}")).to be_truthy
      end

      it "should not fetch the private#{access_modifier} repository" do
        expect(Repository.pub.map(&:access).
          include?("private#{access_modifier}")).to be_falsy
      end
    end
  end
end
