BASE           = ..
PUB_SYNCFILES  = registry-expanded.turtle registry.rdf registry.turtle README
WORK_SYNCFILES = 
SYNCDIRS       =

DEPLOY_FILES         = registry.rdf registry-expanded.rdf $(DEPLOY_DIR)/logics/CommonLogic/index
EXPANDED_DATASET     = registry-expanded.ntriples
DOL_INFERENCES       = $(LIB)/dol-inferences-beyond-owl.n3
OWL_INFERENCES       = $(LIB)/some-owl-inferences.n3
DOL_RDF_VOCAB	     = ../syntax/dol-rdf.owl
STANDARD_VOCAB	     = ../syntax/standardization.owl
TODO_VOCAB	     = ../syntax/todo.owl
EYEBALL_FIXES	     = eyeball-fixes.rdf # some things eyeball reports missing, even though they actually exist
REGISTRY_NS          = http://purl.net/dol/
EYEBALL_DEFAULT_ARGS = -assume $(DOL_RDF_VOCAB) -assume $(STANDARD_VOCAB) -assume $(TODO_VOCAB) -assume $(DCTERMS) -assume $(SKOS) -assume $(OWL) -assume $(EYEBALL_FIXES)

include $(BASE)/Makefile.vars
include $(BASE)/Makefile.in
include Makefile.vars
include ../syntax/Makefile.in

all: $(DEPLOY_FILES)

# Eyeball must be last, as it usually fails
test: registry-with-tbox.rdf registry.eyeball

# validate RDF with Eyeball
%.eyeball: %.rdf
	eyeball $(EYEBALL_DEFAULT_ARGS) -check $<

# Registry TBox (the OWL ontology that defines the vocabulary of the graph) and ABox (the actual graph) combined, for the purpose of validating (manually, known to work with HermiT in Protégé 4.1) whether the ABox is consistent wrt. the TBox.
registry-with-tbox.rdf: registry-expanded.ntriples
	cwm --n3 $< --rdf $(DOL_RDF_VOCAB) > $@

# 1. apply the N3 ruleset to expand the core dataset to the expanded dataset; in detail:
#    cwm --n3 $<                      # parse the input as N3 (a superset of Turtle)
#    --rdf $(BASE)/syntax/dol-rdf.owl # parse the ontology as RDF/XML
#    --n3 $(DOL_INFERENCES)           # load DOL-specific inference rules (particularly those that can't be represented in OWL, but only in FOL)
#    $(OWL_INFERENCES)                # load general OWL (and RDFS and RDF) inference rules (just a relevant subset of the actual rules, implemented ad hoc according to our needs)
#    --think                          # apply the inference rules until they lead to no more expansions
#    --ntriples                       # create N-Triples output for easy linewise post-processing
#    $(CWM_DEFAULT_ARGS)
# 2. remove leading whilespace
# 3. filter out any triples whose subjects are not from the namespace of this dataset.  This includes blank nodes, which are just used for editorial comments so far
# 4. filter out triples containing blank nodes in any component.  Many blank nodes are not relevant for the dataset (e.g. artifacts from the RDF serialization of the OWL ontology, editorial comments, etc.), and those, that are, are not supported by our approach.
# 5. filter out triples with certain annotation properties (here: editorial comments)
%-expanded.ntriples: %.turtle $(DOL_INFERENCES) $(OWL_INFERENCES)
	cwm --n3 $< --rdf $(BASE)/syntax/dol-rdf.owl --n3 $(DOL_INFERENCES) $(OWL_INFERENCES) --think --ntriples $(CWM_DEFAULT_ARGS) \
	| perl -pe 's/^[[:space:]]*//' \
        | grep '^<http://purl\.net/dol/' \
        | grep -v '^<http://purl\.net/dol/1\.0/rdf#' \
	| grep -vE '^<[^>]+>[^<]+(_:|<http://example\.org/todo#)' \
	> $@

# convert expanded N-Triples datasets to Turtle
%-expanded.turtle: %-expanded.ntriples
	cwm --n3=tv $< > $@

# Output all distinct subject URIs (and blank node IDs) that occur in the dataset.
# Omit any namespaces we are not interested in deploying.
resource-uris: $(EXPANDED_DATASET)
	awk '{print gensub("<([^>]+)>", "\\1", 1, $$1)}' $< \
	| sort \
	| uniq \
	> $@

# Make sure that all directories exist in whose paths we have resources.
# We use one directory path as a representative for generating all of them.
$(DEPLOY_DIR)/logics: resource-uris
	perl -lne 'print $$1 if m@^http://purl\.net/dol/((?:[^/]+/)*)[^/]+@' $< \
	| sort \
	| uniq \
	| while read directory ; do \
		echo $$directory ; \
		target=$(DEPLOY_DIR)/$$directory ; \
		$(MKDIR) $$target ; \
		cp .htaccess $$target ; \
	  done

# Use the URI of one resource as a representative for generating all split files
# For each resource, …
# 1. read all triples having this resource as a subject
# 2. output them to a self-contained RDF/XML file named after the resource
$(DEPLOY_DIR)/logics/CommonLogic/index: resource-uris $(DEPLOY_DIR)/logics
	function do_split() { \
		resource_pattern=$$1 ; \
		main_resource=$$2 ; \
		out_file=$(DEPLOY_DIR)/$${main_resource#$(REGISTRY_NS)} ; \
		if [[ -d $$out_file ]]; then out_file=$${out_file}/index; fi ; \
		grep "$${resource_pattern}" $(EXPANDED_DATASET) \
		| cwm --n3 --rdf $(CWM_DEFAULT_ARGS) \
		> $$out_file ; \
	} ; \
	while read resource ; do \
		echo $$resource ; \
		do_split "^<$$resource>" $$resource ; \
	  done < $< ; \

.PHONY: all test
