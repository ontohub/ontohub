require 'spec_helper'

describe OntologiesController do

  it { should     route(:post,  'repositories/repopath/ontologies/retry_failed'  ).to(repository_id: 'repopath', action: :retry_failed ) }

end
