module FlashHelper
  
  FLASH_TYPES = [:error, :success, :info]
  
  def flash_messages
    out = ''
    flash.each do |type, message|
      unless type == :recaptcha_error
        type    = :info unless FLASH_TYPES.include?(type)
        message = '<a class="close" data-dismiss="alert">×</a>'.html_safe << h(message)
        
        out << content_tag(:div, message, :class => "flash alert alert-#{type}")
      end
    end
    out.html_safe
  end

  def format_error_message(msg)
    return if msg.blank?
    preserve content_tag(:div, msg, class: 'alert alert-danger error-message')
  end
  
end
