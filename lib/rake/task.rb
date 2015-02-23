class Rake::Task
  # methods found on http://blog.jayfields.com/2008/02/rake-task-overwriting.html
  def overwrite(&block)
    @actions.clear
    prerequisites.clear
    enhance(&block)
  end
  def abandon
    prerequisites.clear
    @actions.clear
  end
end
