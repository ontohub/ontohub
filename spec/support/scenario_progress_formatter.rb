require 'cucumber/formatter/progress'

class ScenarioProgressFormatter < Cucumber::Formatter::Progress
  SCENARIO_INDENT = 2
  EXCEPTION_INDENT = SCENARIO_INDENT + 2

  def initialize(runtime, path_or_io, options)
    super(runtime, path_or_io, options)
    @failed_scenario_steps = []
  end

  def after_feature_element(feature_element)
    super(feature_element)
    @io.puts
    @io.flush
  end

  def before_feature_element(feature_element)
    super(feature_element)
    @processed_steps = [@current_feature]
    @failed = false
  end

  def after_feature_element(feature_element)
    @failed_scenario_steps << @processed_steps if @failed
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
    @io.flush
  end

  def tag_name(tag_name)
    tag = format_string(tag_name, :tag).indent(SCENARIO_INDENT)
    @processed_steps << tag
    @io.puts(tag)
    @io.flush
  end

  def feature_name(keyword, name)
    @current_feature = "Feature: #{name}"
    @io.puts("#{keyword}: #{name}")
    @io.flush
  end

  def background_name(keyword, name, file_colon_line, source_indent)
    @processed_steps << "Background: #{name}"
    print_feature_element_name(keyword, name, file_colon_line, source_indent)
  end

  def scenario_name(keyword, name, file_colon_line, source_indent)
    @processed_steps << "Scenario: #{name}"
    print_feature_element_name(keyword, name, file_colon_line, source_indent)
  end

  def step_name(keyword, step_match, status, source_indent, background, file_colon_line)
    name_to_report = format_step(keyword, step_match, status, source_indent)
    @processed_steps << "Step: #{name_to_report}"
  end

  def exception(exception, status)
    return if @hide_this_step
    @processed_steps << format_exception(exception, status, EXCEPTION_INDENT)
    @failed = true
  end

  private

  def print_feature_element_name(keyword, name, file_colon_line, source_indent)
    names = name.empty? ? [name] : name.split("\n")
    line = "#{keyword}: #{names[0]}".indent(SCENARIO_INDENT)
    @io.print(line)
    @io.print(' [...]') if names[1..-1].present?
    @io.flush
  end

  def print_summary(features)
    print_steps(:pending)
    print_failure_details
    print_stats(features, @options)
    print_snippets(@options)
    print_passing_wip(@options)
  end

  def print_failure_details
    if @failed_scenario_steps.any?
      @io.puts(format_string("(::) steps of failed scenarios (::)", :failed))
      @io.puts
      @io.flush
    end

    @failed_scenario_steps.each do |failed_scenario|
      failed_scenario.each do |step|
        @io.puts step.indent(SCENARIO_INDENT)
      end
      @io.puts
    end
    @io.puts
    @io.flush
  end

  def format_exception(e, status, indent)
    message = "#{e.message} (#{e.class})".force_encoding("UTF-8")
    if ENV['CUCUMBER_TRUNCATE_OUTPUT']
      message = linebreaks(message, ENV['CUCUMBER_TRUNCATE_OUTPUT'].to_i)
    end

    string = "#{message}\n#{e.backtrace.join("\n")}".indent(indent)
    format_string(string, status)
  end
end
