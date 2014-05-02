package com.google.gwt.user.client.ui.events;

/**
 * A class that has filter selection handlers.
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public interface HasFilterSelectionHandlers {

	/**
	 * Adds a filter selection handler to the list of handlers
	 * 
	 * @param handler the filter selector handler to add to the list
	 */
	public void addFilterSelectionHandler(FilterSelectionHandler handler);
}
