class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    
    user ||= User.new # guest user (not logged in)
    
    if user.admin?
      can { true }
    elsif user.id
      # Ontologies
      can [:edit, :update, :destroy], Ontology do |subject|
        subject.permission?(:owner, user)
      end
      can [:new, :create], Ontology
      
      # Team permissions
      can [:create, :show, :index], Team
      can [:edit, :update, :destroy], Team do |subject|
        subject.admin?(user)
      end
      
    end
    
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
