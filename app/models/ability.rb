class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    
    user ||= User.new # guest user (not logged in)
    
    if user.admin?
      can { true }
    elsif user.id
      # Repositories
      can [:new, :create], Repository
      can [:write], Repository do |subject|
        subject.permission?(:editor, user)
      end
      can [:edit, :update, :destroy, :permissions], Repository do |subject|
        subject.permission?(:owner, user)
      end

      # Ontology
      can :manage, Ontology do |subject|
        subject.permission?(:editor, user)
      end
      
      # Logics
      can [:edit, :update], Logic do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], Logic do |subject|
        subject.permission?(:owner, user)
      end
      can [:new, :create], Logic
      
      # LogicMappings
      can [:edit, :update], LogicMapping do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LogicMapping do |subject|
        subject.permission?(:owner, user)
      end
      can [:new, :create], LogicMapping
      
      # LanguageMappings
      can [:edit, :update], LanguageMapping do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LanguageMapping do |subject|
        subject.permission?(:owner, user)
      end
      can [:new, :create], LanguageMapping

      # LogicAdjoints
      can [:edit, :update], LogicAdjoint do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LogicAdjoint do |subject|
        subject.permission?(:owner, user)
      end
      can [:new, :create], LogicAdjoint

      # LanguageAdjoints
      can [:edit, :update], LanguageAdjoint do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], LanguageAdjoint do |subject|
        subject.permission?(:owner, user)
      end
      can [:new, :create], LanguageAdjoint
      
      # Languages
      can [:edit, :update], Language do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], Language do |subject|
        subject.permission?(:owner, user)
      end
      can [:new, :create], Language

      # Serializations
      can [:new, :create, :destroy, :edit, :update], Serialization
      
      # Team permissions
      can [:create, :show, :index], Team
      can [:edit, :update, :destroy], Team do |subject|
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
      
    end
    
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
