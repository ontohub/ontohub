require 'dsl/repo.rb'

namespace :repos do
  task :create => :environment do
    init Rails.root.join('tmp', 'rake', 'repos', 'create') # initialize the quick repo creation

    repo_clone 'colore3', 'https://github.com/tillmo/colore3.git'     # use this repository
    add_url_map 'http://colore.oor.net', 'http://localhost/colore3'   # add an url map for this repository
    add_url_map 'https://colore.oor.net', 'https://localhost/colore3' #   any number of times
    save_to_ontohub                                                   # save to database

    # repeat as often as one likes for more repositories

    repo_clone 'cliftest', 'https://github.com/eugenk/cliftest.git'
    save_to_ontohub

    repo_clone 'importing_owl', 'https://github.com/eugenk/importing_owl.git'
    save_to_ontohub
  end
end
