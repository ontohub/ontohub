class CreateSlugForExistingLogics < ActiveRecord::Migration
  def up
    methods_needed = [:set_slug, :slug, :slug=]
    if methods_needed.all? { |m| Logic.new.respond_to?(m, true) }
      Logic.find_each { |l| l.send(:set_slug) }
    end
  end

  def down
    methods_needed = [:set_slug, :slug, :slug=]
    if methods_needed.all? { |m| Logic.new.respond_to?(m, true) }
      Logic.find_each { |l| l.send(:slug=, nil) }
    end
  end
end
