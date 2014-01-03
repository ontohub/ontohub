require 'spec_helper'

describe HomeController do

  describe "show" do
    before { get :show }
    it { should respond_with :success }
    it { should render_template :show }
  end

end
