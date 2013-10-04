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
		RootPanel rootPanel = RootPanel.get("OntologySearch");
		if (rootPanel != null) {
			OntologySearch ontologySearchBar = new OntologySearch();
			rootPanel.add(ontologySearchBar);
		}
	}
}
