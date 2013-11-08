module Repository::Scopes
  extend ActiveSupport::Concern

  included do
    equal_scope *%w(
      path
      state
    )
  end

end
