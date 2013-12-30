package org.ontohub.shared;

import java.util.LinkedList;

/**
 * A list of ontologies.
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class OntologyList extends LinkedList<Ontology>{

	/**
	 * Generated serial version
	 */
	private static final long serialVersionUID = -3165438086598414639L;
	
	private final Integer page;
	private final Integer ontologiesPerPage;
	private final Integer ontologiesInSet;

	public OntologyList(Integer page, Integer ontologiesPerPage, Integer ontologiesInSet) {
		this.page = page;
		this.ontologiesPerPage = ontologiesPerPage;
		this.ontologiesInSet = ontologiesInSet;
	}

	public final Integer getPage() {
		return page;
	}

	public final Integer getOntologiesPerPage() {
		return ontologiesPerPage;
	}

	public final Integer getOntologiesInSet() {
		return ontologiesInSet;
	}

};