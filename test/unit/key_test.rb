require 'test_helper'

class KeyTest < ActiveSupport::TestCase

  should have_db_column('user_id').of_type(:integer)
  should have_db_column('key').of_type(:text)
  should have_db_column('fingerprint').of_type(:string)

  should belong_to :user
  should strip_attribute :key

  context 'creating a key' do
    setup do
      @user = FactoryGirl.create :user
    end

    context 'that is valid' do
      setup do
        @key = @user.keys.create! \
          name: 'My ecdsa key',
          key:  'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFoY047dBuHiWYi67TgKG0oKinCH0cNgJZu3lGIiUXCK0oXqktFrxeJjJnF9VG0ZLp+7tLl+mvmunNfBDVG9b7E= test@example'
      end
      
      should 'have fingerprint' do
        assert_equal "0bed5f609d521fb1aa93a79dc408fdd3", @key.fingerprint
      end

      should 'have shell_id' do
        assert_equal "key-#{@key.id}", @key.shell_id
      end
    end

    context 'that is invalid' do
      setup do
        @key = @user.keys.create \
          name: 'My ecdsa key',
          key:  'ecdsa-sha2-nistp256 AAAAE2VjZtbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFoY047dBuHiWYi67TgKG0oKinCH0cNgJZu3lGIiUXCK0oXqktFrxeJjJnF9VG0ZLp+7tLl+mvmunNfBDVG9b7E= test@example'
      end
      
      should 'have invalid key' do
        assert_equal ["is not a public key file."], @key.errors[:key]
      end

      should 'have no fingerprint' do
        assert_nil @key.fingerprint
      end
    end
  end
  
end
