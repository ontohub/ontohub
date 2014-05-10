module OntologyVersion::Numbers
  extend ActiveSupport::Concern

  included do
    before_create :generate_number
  end

  protected

  def generate_number
    self.number = connection.select_value("SELECT MAX(number) FROM #{self.class.table_name} WHERE ontology_id=#{ontology_id.to_i}").to_i + 1
  end

end
