# http://stackoverflow.com/questions/14972253/simpleform-default-input-class
# https://github.com/plataformatec/simple_form/issues/316
# https://gist.github.com/adamico/6510093
 
inputs = %w[
  CollectionSelectInput
  DateTimeInput
  FileInput
  GroupedCollectionSelectInput
  NumericInput
  PasswordInput
  RangeInput
  StringInput
  TextInput
]
 
inputs.each do |input_type|
  superclass = "SimpleForm::Inputs::#{input_type}".constantize
 
  new_class = Class.new(superclass) do
    def input_html_classes
      super.push('form-control')
    end
  end
 
  Object.const_set(input_type, new_class)
end
 
SimpleForm.setup do |config|
  config.wrappers :bootstrap3, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :min_max
    b.use :maxlength
    b.use :placeholder
    
    b.optional :pattern
    b.optional :readonly
    
    b.wrapper tag: 'div', class: 'col-md-4 col-xs-12' do |ba|
      ba.use :label
    end

    b.wrapper tag: 'div', class: 'col-md-8 col-xs-12' do |ba|
      ba.use :input
      ba.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
    end
  end

  config.form_class = 'simple_form form-horizontal'

  config.default_wrapper = :bootstrap3
end
