require "rspec/core/formatters/base_text_formatter"

class DocumentationProgressFormatter < RSpec::Core::Formatters::BaseTextFormatter
  MAX_GROUP_LEVEL = 2

  def initialize(output)
    super(output)
    @group_level = 0
  end

  def example_group_started(example_group)
    super(example_group)

    if @group_level < MAX_GROUP_LEVEL
      output.puts if @group_level == 0
      output.puts
      output.print "#{current_indentation}#{example_group.description.strip}"
      output.print ' '
    end

    @group_level += 1
  end

  def example_group_finished(example_group)
    @group_level -= 1
  end

  def stop
    output.puts
    output.puts
  end

  def example_passed(example)
    super(example)
    output.print passed_output(example)
  end

  def example_pending(example)
    super(example)
    output.print pending_output(example)
  end

  def example_failed(example)
    super(example)
    output.print failure_output(example)
  end

  def failure_output(example)
    failure_color('F')
  end

  def passed_output(example)
    success_color('.')
  end

  def pending_output(example)
    pending_color('*')
  end

  def current_indentation
    '  ' * @group_level
  end
end
