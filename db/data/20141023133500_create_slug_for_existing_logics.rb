class CreateSlugForExistingLogics < ActiveRecord::Migration
  def up
    methods_needed = [:set_slug, :slug, :slug=]
    performable = methods_needed.all? { |m| Logic.new.respond_to?(m, true) }
    Logic.find_each do |logic|
      logic.send(:set_slug)
      logic.save!
    end if performable
  end

  def down
    methods_needed = [:set_slug, :slug, :slug=]
    performable = methods_needed.all? { |m| Logic.new.respond_to?(m, true) }
    Logic.find_each do |logic|
      logic.send(:slug=, nil)
      logic.save!
    end if performable
  end
end
