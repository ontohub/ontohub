# Create Admin User.
@user = User.create!(
  {
    email:    'admin@example.com',
    name:     'admin',
    admin:    true,
    password: 'changeme'
  },
  as: :admin
)

@user.confirm!

# Create Team.
@team = Team.create! \
  name:       'Lorem Ipsum'

@team.admin_user = @user
@team.save!

# Create some other users.
%w(Bob Alice Carol Dave Ted).each_with_index do |name, i|
  @user = User.create! \
    email:    "#{name}@example.com",
    name:     name,
    password: 'changeme'

  @user.confirm!

  # Add two users to the first team.
  @team.users << @user if i < 2
end
