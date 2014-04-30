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
	public final native int getOntologiesPerPage() /*-{ return this.ontologiesPerPage; }-*/;
	public final native int getOntologiesInSet() /*-{ return this.ontologiesInSet; }-*/;
	public final native JsArray<Ontology> getOntologies() /*-{ return this.ontologies; }-*/;
}
