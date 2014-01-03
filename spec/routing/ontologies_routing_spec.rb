require 'spec_helper'

describe OntologiesController do

  it { should     route(:post,  'repositories/repopath/ontologies/retry_failed'  ).to(repository_id: 'repopath', action: :retry_failed ) }
  it { should     route(:post,  'repositories/repopath/ontologies/id/retry_failed').to(repository_id: 'repopath', action: :retry_failed, id: 'id' ) }

end
