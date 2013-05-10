class Cart < ActiveRecord::Base
  has_many :cart_items, :dependent => :destroy
  
  def empty?
    cart_items.empty?
  end
  
  def add(item)
    cart_items.create(cart_id: id, ontology_version_id: item.id)
    
  end
end