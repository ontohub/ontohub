require 'spec_helper'
require 'cancan/matchers'

describe Ability do

  let(:user){   create :user } # regular user
  let(:owner){  create :user } # owner

  context 'Repository' do
    let(:editor){ create :user } # editor
    let(:reader){ create :user } # reader
    let(:item){   create(:permission, subject: owner, role: 'owner').item }

    before do
      create(:permission, subject: editor, role: 'editor', item: item)
      create(:permission, subject: reader, role: 'reader', item: item)
    end

    context 'guest' do
      subject(:ability){ Ability.new(User.new) }

      it 'not be allowed: new, create' do
        [:new, :create].each do |perm|
          should_not be_able_to(perm, Repository.new)
        end
      end

      it 'be allowed: show' do
        should be_able_to(:show, Repository.new)
      end

      it 'not be allowed some actions' do
        [:edit, :update, :destroy, :write].each do |perm|
          should_not be_able_to(perm, item)
        end
      end
    end

    context 'reader' do
      subject(:ability){ Ability.new(reader) }

      it 'be allowed: new, create' do
        [:new, :create].each do |perm|
          should be_able_to(perm, Repository.new)
        end
      end

      it 'not be allowed some actions' do
        [:edit, :update, :destroy, :write].each do |perm|
          should_not be_able_to(perm, item)
        end
      end

      it 'be allowed: show' do
        should be_able_to(:show, create(:repository))
      end
    end

    context 'owner' do
      subject(:ability){ Ability.new(owner) }

      it 'be allowed: new, create' do
        [:new, :create].each do |perm|
          should be_able_to(perm, Repository.new)
        end
      end

      it 'be allowed: edit, update, destroy, permissions, write' do
        [:show, :edit, :update, :destroy, :permissions].each do |perm|
          should be_able_to(perm, item)
        end
      end

      it 'not be allowed on other: edit, update, destroy, permissions' do
        [:edit, :update, :destroy, :permissions].each do |perm|
          should_not be_able_to(perm, create(:repository))
        end
      end
    end

    context 'editor' do
      subject(:ability){ Ability.new(editor) }

      it 'be allowed: write' do
        [:show, :write].each do |perm|
          should be_able_to(perm, item)
        end
      end

      it 'not be allowed: edit, update, destroy, permissions' do
        [:edit, :update, :destroy, :permissions].each do |perm|
          should_not be_able_to(perm, item)
        end
      end
    end
  end

  context 'Private Repository' do
    let(:editor){ create :user } # editor
    let(:reader){ create :user } # reader
    let(:item){   create(:repository, access: 'private_rw', user: owner) }

    before do
      create(:permission, subject: editor, role: 'editor', item: item)
      create(:permission, subject: reader, role: 'reader', item: item)
    end

    context 'guest' do
      subject(:ability){ Ability.new(User.new) }

      it 'not be allowed: anything' do
        [:show, :update, :write].each do |perm|
          should_not be_able_to(perm, item)
        end
      end
    end

    context 'reader' do
      subject(:ability){ Ability.new(reader) }

      it 'not be allowed: to manage' do
        [:update, :write].each do |perm|
          should_not be_able_to(perm, item)
        end
      end

      it 'be allowed: to read' do
        should be_able_to(:show, item)
      end
    end

    context 'editor' do
      subject(:ability){ Ability.new(editor) }

      it 'be allowed: to read and manage' do
        [:show, :write].each do |perm|
          should be_able_to(perm, item)
        end
      end
    end

    context 'owner' do
      subject(:ability){ Ability.new(owner) }

      it 'be allowed: everything' do
        [:show, :update, :write].each do |perm|
          should be_able_to(perm, item)
        end
      end
    end
  end

  context 'Private read-only Repository' do
    let(:editor){ create :user } # editor
    let(:reader){ create :user } # reader
    let(:item){   create(:repository, access: 'private_r', user: owner) }

    before do
      create(:permission, subject: editor, role: 'editor', item: item)
      create(:permission, subject: reader, role: 'reader', item: item)
    end

    context 'guest' do
      subject(:ability){ Ability.new(User.new) }

      it 'not be allowed: anything' do
        [:show, :update, :write].each do |perm|
          should_not be_able_to(perm, item)
        end
      end
    end

    context 'reader, editor, owner' do
      it 'not be allowed: to write' do
        [reader, editor, owner].each do |role|
          Ability.new(role).should_not be_able_to(:write, item)
        end
      end

      it 'be allowed: to read' do
        [reader, editor, owner].each do |role|
          Ability.new(role).should be_able_to(:show, item)
        end
      end
    end

    context 'update:' do
      it 'reader, editor should be allowed' do
        [reader, editor].each do |role|
          Ability.new(role).should_not be_able_to(:update, item)
        end
      end

      it 'owner should not be allowed' do
        Ability.new(owner).should be_able_to(:update, item)
      end
    end
  end

  context 'Team' do
    let(:other){ create :user }
    let(:memberteam){ create(:team_user, user: other).team }
    let(:otherteam){  create(:team_user, user: other).team }

    subject(:ability){ Ability.new(user) }

    before do
      memberteam.users << user
    end

    context 'admin' do
      it 'be allowed: edit, update, destroy' do
        [:edit, :update, :destroy].each do |perm|
          should be_able_to(perm, create(:team_user, user: user).team)
        end
      end
    end

    context 'member' do
      it 'be allowed: create, show, index' do
        [:create, :show, :index].each do |perm|
          should be_able_to(perm, Team.new)
        end
      end

      it 'not be allowed: edit, update, destroy (without admin on team)' do
        [:edit, :update, :destroy].each do |perm|
          should_not be_able_to(perm, @memberteam)
        end
      end

      it 'not be allowed: edit, update, destroy (without being on team)' do
        [:edit, :update, :destroy].each do |perm|
          should_not be_able_to(perm, otherteam)
        end
      end
    end
  end

  context 'Comment' do
    let(:comment){ create :comment }

    context 'author' do
      subject(:ability){ Ability.new(comment.user) }

      it 'destroy his own comment' do
        should be_able_to(:destroy, comment)
      end

      it 'not be allowed to destroy others comment' do
        should_not be_able_to(:destroy, create(:comment))
      end
    end

    context 'admin' do
      subject(:ability){ Ability.new(create :admin) }

      it 'destroy others comment' do
        should be_able_to(:destroy, comment)
      end
    end

    context 'comments repository owner' do
      subject(:ability){ Ability.new(owner) }

      before do
        create(:permission, subject: owner, role: 'owner', item: comment.commentable.repository)
      end

      it 'destroy others comments for his repository' do
        should be_able_to(:destroy, comment)
      end
    end

    context 'comments repository editor' do
      subject(:ability){ Ability.new(owner) }
      before do
        create(:permission, subject: owner, role: 'editor', item: comment.commentable.repository)
      end

      it 'not destroy others comments for his repository' do
        should_not be_able_to(:destroy, comment)
      end
    end
  end
end
