class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    
    user ||= User.new # guest user (not logged in)
    
    if user.admin?
      can { true }
    elsif user.id
      # Repositories
      can [:create], Repository
      can :show, Repository do |subject|
        if subject.is_private
          subject.permission?(:reader, user) ||
          subject.permission?(:editor, user) ||
          subject.permission?(:owner, user)
        else
          true
        end
      end
      can [:write], Repository do |subject|
        subject.permission?(:editor, user) or subject.public_rw?
      end
      can [:update, :destroy, :permissions], Repository do |subject|
        subject.permission?(:owner, user)
      end

      # Ontology
      can :manage, Ontology do |subject|
        subject.permission?(:editor, user)
      end
      
      # Logics
      can [:update], Logic do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], Logic do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], Logic
      
      # LogicMappings
      can [:update], LogicMapping do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LogicMapping do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], LogicMapping
      
      # LanguageMappings
      can [:update], LanguageMapping do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LanguageMapping do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], LanguageMapping

      # LogicAdjoints
      can [:update], LogicAdjoint do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LogicAdjoint do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], LogicAdjoint

      # LanguageAdjoints
      can [:update], LanguageAdjoint do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LanguageAdjoint do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], LanguageAdjoint
      
      # Languages
      can [:update], Language do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], Language do |subject|
        subject.permission?(:owner, user)
      end
      can [:create], Language

      # Serializations
      can [:create, :destroy, :update], Serialization
      
      # Team permissions
      can [:create, :read], Team
      can [:update, :destroy], Team do |subject|
        subject.admin?(user)
      end
      
      # Comments
      can [:create], Comment
      can [:destroy], Comment do |subject|
        subject.user == user || subject.commentable.permission?(:owner, user)
      end
      
      can [:create, :destroy], Metadatum do |subject|
        # TODO tests written?
        subject.user == user || subject.metadatable.permission?(:editor, user)
      end

      can :read, Category
    else
      can :show, Repository do |subject|
        !subject.is_private
      end

      can :read, Category
    end
    
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
