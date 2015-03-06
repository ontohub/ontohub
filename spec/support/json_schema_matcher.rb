RSpec::Matchers.define :match_json_schema do |schema|
  match do |text|
    JSON::Validator.validate!(schema, text, strict: true)
  end
end