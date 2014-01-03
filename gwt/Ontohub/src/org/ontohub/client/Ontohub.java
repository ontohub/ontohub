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
			boolean asFilter = rootPanel.getElement().getAttribute("role").equals("filter");
			boolean paginated = rootPanel.getElement().getAttribute("pagination").equals("paginated");
			
			// Add search bar
			OntologySearch ontologySearchBar = new OntologySearch();
			rootPanel.add(ontologySearchBar);
			
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
