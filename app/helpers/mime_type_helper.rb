module MimeTypeHelper

  def get_mime_string(filename, mimetype)

    extension = File.extname(filename)[1..-1]

    case extension
    when 'rb'
      'text/x-ruby'
    when 'owl'
      'text/html'
    when 'xml'
      'text/html'
    else
      mimetype.to_s
    end

  end

  def is_mime_type_editable?(current_file)
    current_file[:mime_type] == 'application/xml' || current_file[:mime_category] == 'text'
  end

end
