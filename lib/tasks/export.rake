namespace :export do
  namespace :logicgraph do
    namespace :to do

      desc 'Export the logic graph to the standard output.'
      task :stdout => :environment do
        Logicgraph.export(nil)
      end

      desc 'Export the logic graph to the http transfer directory.'
      task :transfer => :environment do
        Logicgraph.export('tmp/transfer/LogicGraph.xml')
      end

    end
  end
end
