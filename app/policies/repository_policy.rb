class RepositoryPolicy < ApplicationPolicy
    attr_reader :user, :repository

    def initialize(user, repository)
      @user = user
      @repository = repository
    end

    def index?
      true
    end

    def show?
      if repository.private?
        repository.permission?(user, :editor, :reader, :owner)
      else
        true
      end
    end

    def write?
      if repository.mirror? || repository.private_r?
        false
      elsif private_rw? || publir_r?
        repository.permission?(user, :editor, :owner)
      elsif public_rw?
        true
      else
        false
      end
    end

    def create?
      !!user.id
    end

    def new?
      create?
    end

    def update?
      false
    end

    def edit?
      update?
    end

    def destroy?
      repository.permission?(:owner, user)
    end

    def scope
      Pundit.policy_scope!(user, record.class)
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope
      end
    end
end
