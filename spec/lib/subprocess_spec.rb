require 'spec_helper'

describe Subprocess do

  it{ expect(Subprocess.run("echo", "what's", "up")).to eq("what's up\n") }
  it{ expect { Subprocess.run 'false' }.to raise_error Subprocess::Error }

end
