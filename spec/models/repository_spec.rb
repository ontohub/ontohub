require 'spec_helper'

describe Repository do
  context 'associations' do
    %i(ontologies permissions).each do |association|
      it { should have_many(association) }
    end
  end

  let(:user)       { create :user }
  let(:repository) { create :repository, user: user }

  context 'a repository with a reserved name should be invalid' do
    let(:repository_invalid) do
      build :repository, user: user, name: 'repositories'
    end
    it 'be invalid' do
      expect(repository_invalid.invalid?).to be(true)
    end

    context 'error messages' do
      before { repository_invalid.invalid? }
      it 'have errors' do
        expect(repository_invalid.errors[:name].any?).to be(true)
      end
    end
  end

  context 'when trying to rename a repository' do
    it 'should fail to validate' do
      repository.name = "#{repository.name}addition"
      expect { repository.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'when deleting a repository' do
    let (:ontology) { create :ontology, repository: repository }

    context 'with ontologies that import internally' do
      it 'should not raise an error' do
        importing = create :ontology, repository: repository
        create :mapping, target: importing, source: ontology, kind: 'import'
        expect { repository.destroy }.not_to raise_error
      end
    end

    context 'with ontologies that are imported externally' do
      it 'should raise an error' do
        repository2 = create :repository
        importing   = create :ontology, repository: repository2
        create :mapping, target: importing, source: ontology, kind: 'import'
        expect { repository.destroy }.to raise_error(Ontology::DeleteError)
      end
    end
  end

  context 'permissions' do
    context 'creating a permission' do
      let(:permission) { repository.permissions.first }

      it 'permission should not be nil' do
        expect(permission).not_to be_nil
      end

      it 'permission should have subject' do
        expect(permission.subject).to eq(user)
      end

      it 'permission should have role owner' do
        expect(permission.role).to eq('owner')
      end
    end

    context 'made private' do
      let(:editor) { create :user }
      let(:readers) { [create(:user), create(:user), create(:user)] }

      before do
        repository.access = 'private_rw'
        repository.save

        create(:permission, subject: editor, role: 'editor', item: repository)
        readers.each { |r| create(:permission, subject: r, role: 'reader', item: repository) }
      end

      context 'not clear reader premissions when saved, but not set public' do
        it 'have three readers' do
          expect(repository.permissions.where(role: 'reader').count).to eq(3)
        end

        context 'change name' do
          before do
            repository.name += "_foo"
            repository.save
          end
          it 'have three readers' do
            expect(repository.permissions.where(role: 'reader').count). to eq(3)
          end
        end
      end

      context 'clear reader premissions when set public' do
        it 'have three readers' do
          expect(repository.permissions.where(role: 'reader').count).to eq(3)
        end

        context 'change access' do
          before do
            repository.access = 'public_r'
            repository.save
          end

          it 'have no readers' do
            expect(repository.permissions.where(role: 'reader').count). to eq(0)
          end
        end
      end
    end
  end
end
