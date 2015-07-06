require 'spec_helper'

describe Repository::Symlink do

  describe 'repository created' do
    let(:repository){ create :repository }
    let(:link){ File.readlink(repository.symlink_name) }

    it('symlink created') { expect(link).to eq(repository.local_path.to_s) }

    describe 'repository destroy' do
      before { repository.destroy }
      it 'symlink removed' do
        expect(repository.symlink_name.exist?).to be(false)
      end
    end
  end

end
