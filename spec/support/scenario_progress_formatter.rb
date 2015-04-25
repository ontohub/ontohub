require 'cucumber/formatter/progress'

class ScenarioProgressFormatter < Cucumber::Formatter::Progress
  SCENARIO_INDENT = 2

  def after_feature_element(feature_element)
    super(feature_element)
    @io.puts
    @io.flush
  end

  def after_background(background)
    @io.puts
    @io.flush
  end

  def before_steps(*_args)
    super(*_args)
    @io.print(' ')
  end

  def tag_name(tag_name)
    tag = format_string(tag_name, :tag).indent(SCENARIO_INDENT)
    @io.puts(tag)
    @io.flush
  end

  def feature_name(keyword, name)
    @io.puts("#{keyword}: #{name}")
    @io.flush
  end

  def background_name(keyword, name, file_colon_line, source_indent)
    print_feature_element_name(keyword, name, file_colon_line, source_indent)
  end

  def scenario_name(keyword, name, file_colon_line, source_indent)
    print_feature_element_name(keyword, name, file_colon_line, source_indent)
  end

  private

  def print_feature_element_name(keyword, name, file_colon_line, source_indent)
    names = name.empty? ? [name] : name.split("\n")
    line = "#{keyword}: #{names[0]}".indent(SCENARIO_INDENT)
    @io.print(line)
    @io.print(' [...]') if names[1..-1].present?
    @io.flush
  end
end
