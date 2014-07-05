# A logic propulation procedure.
#
# TODO Transform this code in an iterator to enable unit testing
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
class LogicPopulation

  def initialize(store)
    @store = store
  end

  def list
    typeIri = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
    labelIri = 'http://www.w3.org/2000/01/rdf-schema#label'
    commentIri = 'http://www.w3.org/2000/01/rdf-schema#comment'
    definedIri = 'http://www.w3.org/2000/01/rdf-schema#isDefinedBy'
    logicTypeIri = 'http://purl.net/dol/1.0/rdf#Logic'

    logicIris = @store.subjects(typeIri, logicTypeIri)
    logicIris.map do |logicIri|
      logicNames = @store.objects(logicIri, labelIri)
      logicDescs = @store.objects(logicIri, commentIri)
      logicDefis = @store.objects(logicIri, definedIri)
      logicName = logicNames == [] ? logicIri : logicNames[0]
      logicDesc = logicDescs == [] ? logicIri : logicDescs[0]
      logicDefi = logicDefis == [] ? logicIri : logicDefis[0]
      Logic.new \
        iri:         logicIri,
        name:        logicName,
        description: logicDesc,
        defined_by:  logicDefi
    end
  end
end

