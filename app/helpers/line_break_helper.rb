module LineBreakHelper
  def get_probable_line_break(resource)
    rn = resource.content.scan(/\r\n/).count
    n = resource.content.scan(/\n/).count - rn

    if(rn > n)
      "\r\n"
    else
      "\n"
    end
  end
end
