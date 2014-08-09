module Admin::StatusHelper
  def class_for_tab(view, tab, number)
    classes = []
    classes << 'active' if view.current?(tab)
    classes << 'disabled' if number == 0
    classes.join(' ')
  end
end
