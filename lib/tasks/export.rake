namespace :export do
  desc 'Export something to the standard output.'
  task :logicgraph => :environment do
    Logicgraph.export(nil)
  end
end
