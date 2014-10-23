class CreateSlugForExistingLogics < ActiveRecord::Migration
  def up
    methods_needed = [:set_slug, :slug, :slug=]
    performable = methods_needed.all? { |m| Logic.new.respond_to?(m, true) }
    Logic.find_each { |l| l.send(:set_slug) } if performable
  end

  def down
    methods_needed = [:set_slug, :slug, :slug=]
    performable = methods_needed.all? { |m| Logic.new.respond_to?(m, true) }
    Logic.find_each { |l| l.send(:slug=, nil) } if performable
  end
end
