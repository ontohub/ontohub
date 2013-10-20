require 'spec_helper'

describe Key do

  it { have_db_column('user_id').of_type(:integer) }
  it { have_db_column('key').of_type(:text) }
  it { have_db_column('fingerprint').of_type(:string) }

  it { belong_to :user }
  it { strip_attribute :key }

  context 'creating a key' do
    let(:user){ create :user }

    context 'that is valid' do
      subject do
        user.keys.create! \
          name: 'My ecdsa key',
          key:  'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFoY047dBuHiWYi67TgKG0oKinCH0cNgJZu3lGIiUXCK0oXqktFrxeJjJnF9VG0ZLp+7tLl+mvmunNfBDVG9b7E= test@example'
      end
      
      its(:fingerprint){ should == "0bed5f609d521fb1aa93a79dc408fdd3" }
      its(:shell_id   ){ should == "key-#{subject.id}" }
    end

    context 'that is invalid' do
      subject do
        user.keys.create \
          name: 'My ecdsa key',
          key:  'ecdsa-sha2-nistp256 AAAAE2VjZtbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFoY047dBuHiWYi67TgKG0oKinCH0cNgJZu3lGIiUXCK0oXqktFrxeJjJnF9VG0ZLp+7tLl+mvmunNfBDVG9b7E= test@example'
      end
      
      it{ subject.errors[:key].should == ["is not a public key file."] }
      its(:fingerprint){ should == nil }
    end
  end
end