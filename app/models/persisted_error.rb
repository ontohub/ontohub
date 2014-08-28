class PersistedError < ActiveRecord::Base
  belongs_to :ontology_version

  attr_accessible :short_message, :message_body
  attr_accessible :raised_error_class, :raised_error_message, :stack_trace
end
