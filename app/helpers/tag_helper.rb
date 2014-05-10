module TagHelper

  def fancy_tag(resource, tags)
    result = ""
    first = true
    tags.each do |tag|
      if (eval "resource." + tag.to_s)
        if block_given?
          result += first ? tag.to_s : (yield tag.to_s)
        else
          result += first ? tag.to_s : ' ' + tag.to_s
        end
        first = false
      end
    end
    result
    #if block_given?
     #   yield
      #else
       # name = resource
      #end

  end


end
