class EntityMapping < ActiveRecord::Base
  belongs_to :source, class_name: "Entity"
  belongs_to :target, class_name: "Entity"
  belongs_to :link
  attr_accessible :link, :source, :target
  KINDS = %w( subsumes is-subsumed equivalent incompatible has-instance instance-of default-relation )

  def to_s
   "#{self.source} → #{self.target}"
  end

  def apply(sentence)
    sentence.text.gsub(source.name, target.name)
  end

  def applicable?(sentence)
    if sentence.is_a?(TranslatedSentence)
      mapping = sentence.entity_mapping
      entity_ids = [mapping.source_id, mapping.target_id]
    else
      entity_ids = sentence.entities.pluck(:id)
    end
    entity_ids.include?(self.source_id)
  end

end
