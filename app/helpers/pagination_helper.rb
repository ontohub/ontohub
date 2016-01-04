module PaginationHelper

  def pagination(collection=nil, **options, &block)
    # call the collection-method if no collection is given
    collection ||= send :collection

    pages = paginate(collection, **options)

    html = ''
    html << pages
    html << capture(&block)
    html << pages
    html.html_safe
  end

end
