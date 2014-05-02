package org.ontohub.client;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.user.client.ui.RootPanel;

/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class Ontohub implements EntryPoint {

	/**
	 * Handles the loading of the ontology search bar.
	 */
	public void onModuleLoad() {

		// Get HTML element with id "OntologySearch"
		RootPanel ontologySearchBarHolder = RootPanel.get("OntologySearch");

		// If a holder exists for the ontology search bar
		if (ontologySearchBarHolder != null) {

			// Get ontology search attributes
			boolean asFilter = ontologySearchBarHolder.getElement().getAttribute("role").equals("filter");
			boolean paginated = ontologySearchBarHolder.getElement().getAttribute("pagination").equals("paginated");

			// Add search bar
			OntologySearch ontologySearchBar = new OntologySearch();
			ontologySearchBarHolder.add(ontologySearchBar);

			// If it works as filter
			if (asFilter) {

				// Display initial list
				ontologySearchBar.updateOntologyWidgetList();
			}

			// Set pagination
			ontologySearchBar.setPaginated(paginated);

		}
	}
}
