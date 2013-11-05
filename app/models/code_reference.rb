class CodeReference < ActiveRecord::Base
  belongs_to :referencee, polymorphic: true

  attr_accessible :begin_column, :begin_line
  attr_accessible :end_column, :end_line
  attr_accessible :referencee, :referencee_id


  def self.from_range(range, referencee, persist=false)
    return if range.nil?
    match = range.match( %r{
      (?<begin_line>\d+)\.
      (?<begin_column>\d+)
      -
      (?<end_line>\d+)\.
      (?<end_column>\d+)}x)
    if match
      reference = self.new(begin_line: match[:begin_line].to_i,
                           begin_column: match[:begin_column].to_i,
                           end_line: match[:end_line].to_i,
                           end_column: match[:end_column].to_i,
                           referencee_id: referencee)
      reference.save if persist
      reference
    end
  end
end
