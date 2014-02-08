# A language propulation procedure.
# 
# TODO Transform this code in an iterator to enable unit testing
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
class LanguagePopulation

  # A triple store with languages
  @store

  def initialize(store)
    @store = store
  end

  def list
    typeIri = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
    labelIri = 'http://www.w3.org/2000/01/rdf-schema#label'
    commentIri = 'http://www.w3.org/2000/01/rdf-schema#comment'
    definedIri = 'http://www.w3.org/2000/01/rdf-schema#isDefinedBy'
    languageTypeIri = 'http://purl.net/dol/1.0/rdf#OntologyLanguage'

    languageIris = @store.subjects(typeIri, languageTypeIri);
    languageIris.map do |languageIri|
      languageNames = @store.objects(languageIri, labelIri)
      languageDescs = @store.objects(languageIri, commentIri)
      languageDefis = @store.objects(languageIri, definedIri)
      languageName = languageNames == [] ? languageIri : languageNames[0]
      languageDesc = languageDescs == [] ? languageIri : languageDescs[0]
      languageDefi = languageDefis == [] ? languageIri : languageDefis[0]
      language = Language.new({
        :iri => languageIri,
        :name => languageName,
        :description => languageDesc,
        :defined_by => languageDefi
      })
      language
    end
  end
end

