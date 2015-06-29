module SettingsValidationWrapper::Validators
  class ClassValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless options[:in].include?(value.class)
        record.errors.add attribute,
          "must have value of one of the classes: #{options[:in]}"
      end
    end
  end

  class DirectoryValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      begin
        Dir.chdir(Rails.root) { value = Pathname.new(value).expand_path }
      rescue
      end
      unless File.directory?(value)
        record.errors.add attribute, 'is not a directory'
      end
    end
  end

  class ElementsArePresentValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.is_a?(Array) && value.all? { |elem| elem.present? }
        record.errors.add attribute,
          'all elements must not be blank'
      end
    end
  end

  class ElementsAreEmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.is_a?(Array) && value.all? { |elem| elem.match(/@/) }
        record.errors.add attribute,
          'all elements must be email addresses'
      end
    end
  end

  class ElementsHaveKeysValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      valid = value.is_a?(Array) && value.all? do |elem|
        options[:keys].all? { |key| !elem[key].nil? }
      end
      unless valid
        record.errors.add attribute,
          "all elements must have those keys: #{options[:keys]}"
      end
    end
  end

  class EmailFromHostValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      fqdn =
        if options[:hostname].respond_to?(:call)
          options[:hostname].call(record)
        else
          options[:hostname]
        end
      unless value.match(/@#{fqdn}\z/)
        record.errors.add attribute,
          "email adress must belong to the fully qualified domain name '#{fqdn}'."
      end
    end
  end

  class ExecutableValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless File.executable?(value)
        record.errors.add attribute, "must be an executable file: #{value}"
      end
    end
  end
end
