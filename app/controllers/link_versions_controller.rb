# 
# Controller for LinkVersions
# 
class LinkVersionsController < InheritedResources::Base
  defaults :collection_name => :versions
  belongs_to :link

  def update
    update!{ resource.link } 
  end

end