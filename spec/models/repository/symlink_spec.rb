require 'spec_helper'

describe Repository::Symlink do

  describe 'repository created' do
    let(:repository){ create :repository }
    let(:link){ File.readlink(repository.symlink_name) }

    it("symlink created"){ link.should == repository.local_path.to_s }

    describe 'repository destroy' do
      before { repository.destroy }
      it("symlink removed"){ repository.symlink_name.exist?.should be_false }
    end
  end

end
