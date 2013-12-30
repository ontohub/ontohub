package org.ontohub.client;

import org.ontohub.shared.Filter;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.JsArray;
import com.google.gwt.user.client.Window;
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
			boolean filteringBySelectors = ontologySearchBarHolder.getElement().getAttribute("filtering").equals("by-selectors");
			
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

			// Set selector visible
			ontologySearchBar.setFilterSelectorsVisible(filteringBySelectors);

			Window.alert(getFilters().toString());
			Window.alert(getFilters().length() + "");
			Window.alert(getFilters().get(0).getName());
		}
	}
	
	public final native JsArray<Filter> getFilters() /*-{ return [ { 'name' : 'Distributed', 'value' : 'DistributedOntology' }, { 'name' : 'Single', 'value' : 'SingleOntology' } ]; }-*/;
}
