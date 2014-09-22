execute 'add-apt-repository ppa:hets/hets' do
  user 'root'
end

execute 'apt-get update' do
  user 'root'
end

apt_repository 'hets' do
  uri          'http://ppa.launchpad.net/hets/hets/ubuntu'
  distribution 'trusty'
  components   ['main']
  keyserver    'keyserver.ubuntu.com'
  key          '2A2314D8'
end

package 'hets' do
  action :install
end

execute 'hets -update' do
  user 'root'
end

