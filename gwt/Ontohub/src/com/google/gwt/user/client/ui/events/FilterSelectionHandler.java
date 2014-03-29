package com.google.gwt.user.client.ui.events;

/**
 * A handler of filter selections.
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public interface FilterSelectionHandler {

	/**
	 * Called back when a filter is selected.
	 * 
	 * @param event the selection of a filter
	 */
	public void onFilterSelection(FilterSelectionEvent event);
}
