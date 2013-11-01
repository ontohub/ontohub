require 'spec_helper'

describe HomeController do
  it { should     route(:get,  '/'  ).to(action: :show) }
end
