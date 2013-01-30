module Entity::Readability
  extend ActiveSupport::Concern
  
  included do
    after_create :strip_fragment, if: :text_contains_iri
    
    def strip_fragment
      self.fragment_name = URI.parse(text_contains_iri).fragment
    end
    
    def text_contains_iri
      text[URI::regexp(ALLOWED_URI_SCHEMAS)]
    end
    
#    def fragment_stripper(string)
#      string.scan(/.*#(.*)>/).flatten[0]
#    end
#    
#    def text_redundancy_checker(kind, name, text)
#      if !("#{text}".include? "#{name}") then
#        return "not_included"
#      elsif "#{kind} "+"#{name}" == "#{text}" then
 #      @namepart = "#{text}".scan(/(.*#).*/).flatten[0].to_s
 #      @textpart = "#{text}".scan(/.*#(.*)>/).flatten[0].to_s
#        stripped_name = h(owl_stripper(name))
#        return h(text).gsub(/#(#{stripped_name})/, content_tag(:strong,stripped_name)).html_safe
#      else
#        return "included"
#      end
#    end
  end
end