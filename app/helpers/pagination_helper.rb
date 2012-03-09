module PaginationHelper
  
  def paginaton(collection, &block)
    pages = paginate(collection)
    
    html = ''
    html << pages
    html << capture_haml(&block)
    html << pages
    html.html_safe
  end
  
end
