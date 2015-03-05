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
      unless File.directory?(value)
        record.errors.add attribute, 'is not a directory'
      end
    end
  end

  class ElementsAreAbsoluteFilepathsValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      valid = value.is_a?(Array) && value.all? do |elem|
        %w(/ ~/).any? { |start| elem.start_with?(start) }
      end
      unless valid
        record.errors.add attribute,
          'all elements must be absolute filepaths'
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

  class ElementsOneExecutableValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.any? { |filepath| File.executable?(filepath) }
        record.errors.add attribute, 'must contain at least one executable file'
      end
    end
  end

  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.match(/@/)
        record.errors.add attribute, 'must be an email address'
      end
    end
  end
end
