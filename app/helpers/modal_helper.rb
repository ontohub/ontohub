module ModalHelper
  def modal_button(button_text, modal_id: 'modal', btn_class: 'btn-danger')
    render partial: '/shared/modal_button', locals: {
      button_text: button_text,
      modal_id: modal_id,
      btn_class: btn_class
    }
  end

  def modal_body(header_text, body_text, path, button_text, modal_id: 'modal',
      method: :delete, btn_class: 'btn-danger', remote: false)
    render partial: '/shared/modal_body', locals: {
      header_text: header_text,
      body_text: body_text,
      path: path,
      method: method,
      button_text: button_text,
      modal_id: modal_id,
      btn_class: btn_class,
      remote: remote
    }
  end
end
