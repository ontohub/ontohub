require 'spec_helper'

describe Subprocess do

  it{ Subprocess.run("echo", "what's", "up").should == "what's up\n" }
  it{ ->{ Subprocess.run 'false' }.should raise_error Subprocess::Error }

end
