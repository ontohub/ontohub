module PaginationHelper
  def pagination(collection = nil, **options, &block)
    # call the collection-method if no collection is given
    collection ||= send :collection

    pages = paginate(collection, **options)

    html = ''
    html << pages
    html << capture(&block)
    html << pages
    html.html_safe
  end

  # Kaminari generates a URL from the params hash. The URL is, however, not
  # compatible to loc/ids.
  # This method builds the loc/id compatible link to the page.
  def build_link_from_request(kaminari_url)
    page, per_page = params_from_kaminari_url(kaminari_url)

    query_string_parts = request.env['QUERY_STRING'].
      split(/;|&/).
      map { |p| p.split('=') }

    query_string_parts = replace_page_params(query_string_parts, page, per_page)
    query_string = build_query_string(query_string_parts)

    [request.env['REQUEST_PATH'], query_string].compact.join('?')
  end

  # Kaminari generates a URL from the params hash. The URL is, however, not
  # compatible to loc/ids.
  # This method extracts the page number and page size from the generated url.
  def params_from_kaminari_url(kaminari_url)
    page =
      if match = kaminari_url.match(/[\?&]page=(\d+)/)
        match[1]
      end
    per_page =
      if match = kaminari_url.match(/[\?&]per_page=(\d+)/)
        match[1]
      end
    [page || 1, per_page]
  end

  private

  def replace_page_params(query_string_parts, page, per_page)
    query_string_parts.reject! { |p| p.first == 'page' } if page
    query_string_parts.reject! { |p| p.first == 'per_page' } if per_page

    query_string_parts << ['page', page] if page
    if per_page && per_page != :default
      query_string_parts << ['per_page', per_page]
    end

    query_string_parts
  end

  def build_query_string(query_string_parts)
    query_string = query_string_parts.map { |p| p.join('=') }.join('&')
    query_string if query_string.present?
  end
end
