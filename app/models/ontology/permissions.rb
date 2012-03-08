module Ontology::Permissions
  extend ActiveSupport::Concern

  included do
    has_many :permissions
  end

  def permission?(user_or_team)
    # Allow any admin user.
    return true if user_or_team.admin? rescue nil

    # Allow if user or team owns ontology.
    return true if owner == user_or_team

    # Allow if user is member of team which owns ontology. 
    return true if user_or_team.teams.include? owner rescue nil

    # Deny otherwise.
    return false
  end
end
