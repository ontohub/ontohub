class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    
    user ||= User.new # guest user (not logged in)
    
    if user.admin?
      can { true }
    elsif user.id
      # Ontologies
      can [:edit, :update], Ontology do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], Ontology do |subject|
        subject.permission?(:owner, user)
      end
      can [:new, :create, :bulk], Ontology
      
      # Logics
      can [:edit, :update], Logic do |subject|
        subject.permission?(:editor, user)
      end
      can [:destroy, :permissions], Logic do |subject|
        subject.permission?(:owner, user)
      end
      can [:new, :create], Logic
      
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
