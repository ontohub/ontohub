class ErrorsController < InheritedResources::Base
  belongs_to :repository, finder: :find_by_path!

  def index
    ontos = parent.ontologies
    @orphans = ontos.select{|o| o.versions.empty? and o.parent.nil?}
    versions = ontos.map{|o| o.versions.last}.select{|v| !v.nil?}
    @failed_versions = versions.select{|v| v.state!="done"}.group_by do |v|
      err = v.state+": "+(v.last_error.nil? ? "" : v.last_error)
      if err.include?("exited with status")
        then err[0,50]+" ... "+err.match("exited with status.*")[0]
      else err.split("\n").first
      end
    end
  end

end
