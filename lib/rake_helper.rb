module RakeHelper
  def self.import_logicgraph(email = nil)
    def save(user, symbol)
      symbol.user = user if symbol.has_attribute? "user_id"
      begin
        symbol.save!
      rescue ActiveRecord::RecordInvalid => e
        puts "Validation-Error: #{e.record} (#{e.message})"
      end
    end

    user = User.find_all_by_admin(true).first
    user = User.find_by_email! email unless nil.nil?

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        system("#{Settings.hets.executable_path} -G")
        LogicgraphParser.parse(File.open(File.join(dir, 'LogicGraph.xml')),
          logic:          Proc.new{ |h| save(user, h) },
          language:       Proc.new{ |h| save(user, h) },
          logic_mapping:  Proc.new{ |h| save(user, h) },
          support:        Proc.new{ |h| save(user, h) })
        end
    end
  end
end
