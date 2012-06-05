BASE = ..
PUB_SYNCFILES = dol-rdf.omn dol-rdf.owl dol-xml.rnc schemas.xml test.dox README
WORK_SYNCFILES = 
SYNCDIRS =

include $(BASE)/Makefile.vars
include $(BASE)/Makefile.in
include Makefile.in

all: onto-vocab.rdf $(DEPLOY_DIR)/1.0/rdf

# TODO consistency check of an OWL ontology with Hets
# $ hets -I -i owl file.omn
# > nodes  // this needs to be automated
# > dg basic NODE-NAME
# > cons-checker Pellet  // or Fact
# > check-consistency

# 1. expand some OWL entailments
# 2. remove leading whilespace
# 3. filter out any triples with subjects from namespaces that are not part of the dataset:
#    * blank nodes: not used in the subgraph that we are interested in
#    * local N3 rules
#    * OWL, RDFS, and annotation vocabularies
onto-vocab.rdf: dol-rdf.owl
	cwm --rdf $< $(OWL) $(RDFS) --n3 $(LIB)/some-owl-inferences.n3 annotate-owl-inverses.n3 --think --ntriples $(CWM_DEFAULT_ARGS) \
	| perl -pe 's/^[[:space:]]*//' \
        | grep -E '^(_:|<http://purl\.net/dol/1\.0)' \
        > $@

$(DEPLOY_DIR)/1.0/rdf: dol-rdf.owl $(DEPLOY_DIR)/1.0
	cp $< $@

$(DEPLOY_DIR)/1.0: 
	$(MKDIR) $@
