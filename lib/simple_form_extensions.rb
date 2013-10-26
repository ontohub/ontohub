# https://github.com/plataformatec/simple_form/wiki/Twitter-Bootstrap-v2-and-simple_form-v2
module WrappedButton
  def wrapped_button(*args, &block)
    template.content_tag :div, :class => "form-group" do
      template.content_tag :div, class: 'col-lg-offset-2 col-lg-10' do
        options = args.extract_options!
        loading = self.object.new_record? ? I18n.t('simple_form.creating') : I18n.t('simple_form.updating')
        options["data-disable-with"] = [loading, options["data-disable-with"]].compact
        options[:class] = ['btn btn-primary', options[:class]].compact
        args << options
        if cancel = options.delete(:cancel)
          submit(*args, &block) + ' ' + I18n.t('simple_form.buttons.or') + ' ' + template.link_to(I18n.t('simple_form.buttons.cancel'), cancel)
        else
          submit(*args, &block)
        end
      end
    end
  end
end

SimpleForm::FormBuilder.send :include, WrappedButton
