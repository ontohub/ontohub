class ActiveRecord::Base
  def self.perform(id, method, *args)
    find(id).send(method, *args)
  end

  def async(method, *args)
    Resque.enqueue(self.class, id, method, *args)
  end
end
