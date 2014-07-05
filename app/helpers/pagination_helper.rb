module PaginationHelper

  def pagination(collection=nil, &block)
    # call the collection-method if no collection is given
    collection ||= send :collection

    pages = paginate(collection)

    html = ''
    html << pages
    html << capture(&block)
    html << pages
    html.html_safe
  end

end
