module TitleHelper

  def page_title
    @page_title || "#{controller_name} - #{action_name}"
  end

end
