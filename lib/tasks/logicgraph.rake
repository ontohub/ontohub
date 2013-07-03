namespace :logicgraph do
  def save(entity)
    entity.user = @user if entity.has_attribute? "user_id"
    begin
      entity.save!
    rescue ActiveRecord::RecordInvalid => e
      puts "Validation-Error: #{e.record} (#{e.message})"
    end
  end
  task :import => :environment do
    @user = User.find_all_by_admin(true).first
    @user = User.find_by_email! ENV['EMAIL'] unless ENV['EMAIL'].nil?
    LogicgraphParser.parse File.open("#{Rails.root}/registry/LogicGraph.xml"),
      logic:          Proc.new{ |h| save(h) },
      language:       Proc.new{ |h| save(h) },
      logic_mapping:  Proc.new{ |h| save(h) },
      support:        Proc.new{ |h| save(h) }
  end
end
