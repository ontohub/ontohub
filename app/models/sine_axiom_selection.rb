# This class implements the SInE axiom selection algorithm proposed in:
#
# K. Hoder and A. Voronkov. Sine qua non for large theory reasoning.
# In Automated Deduction - CADE-23 - 23rd International Conference on Automated
# Deduction, Wroclaw, Poland, July 31 - August 5, 2011. Proceedings,
# pages 299–314, 2011.
class SineAxiomSelection < ActiveRecord::Base
  # We want to have all the functionality of SineAxiomSelection in other
  # models as well.
  include SineAxiomSelection::ClassBody
end
