#
# states:
# * pending
# * downloading
# * processing
# * failed
# * done
#
module OntologyVersion::States
  extend ActiveSupport::Concern

  include StateUpdater

  TERMINAL_STATES = %w(failed done)

  included do
    after_save :after_update_state, if: :state_changed?
  end

  def state_message
    msg = [state]
    if last_error
      lines = last_error.split("\n")
      if (ind=lines.index("*** Error:")) and (out = lines[ind+1]).present?
        i = ind+2
        while lines[i] and !lines[i].include?("hets: user error") do
          out += " "+lines[i]
          i+=1
        end
        msg << out.sub(URI.regexp,"...").sub(/ \/[A-Za-z0-9\/.]*/," ...")
      elsif last_error.include?("exited with status")
        msg << last_error[0,50]+" ... "+last_error.match("exited with status.*")[0]
      else
        msg << lines.first
      end
    end
    msg.join(": ")
  end

  protected

  def after_update_state
    ontology.state = state.to_s
    ontology.save!
    if ontology.distributed?
      ontology.children.update_all state: ontology.state
    end
  end

end
