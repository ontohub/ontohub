package org.ontohub.shared;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.core.client.JsArray;

/**
 * The response of an ontology search
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class SearchResponse extends JavaScriptObject {
	protected SearchResponse() {}
	public final native int getPage() /*-{ return this.page; }-*/;
	public final native int getResultsInPage() /*-{ return this.resultsInPage; }-*/;
	public final native int getResultsInSet() /*-{ return this.resultsInSet; }-*/;
	public final native JsArray<Ontology> getResults() /*-{ return this.results; }-*/;
}
