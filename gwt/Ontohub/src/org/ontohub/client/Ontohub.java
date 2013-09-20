package org.ontohub.client;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.user.client.ui.RootPanel;

/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class Ontohub implements EntryPoint {

	/**
	 * This is the entry point method.
	 */
	public void onModuleLoad() {
		OntologySearchBar ontologySearchBar = new OntologySearchBar();
		RootPanel.get("OntologySearchBarContainer").add(ontologySearchBar);
	}
}
