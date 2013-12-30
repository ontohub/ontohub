package org.ontohub.shared;

import com.google.gwt.core.client.JavaScriptObject;

/**
 * A JSON object that describes an ontology keyword for search.
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class Keyword extends JavaScriptObject {
	protected Keyword() {}
	public final native String getText() /*-{ return this.text; }-*/;
	public final native String getType() /*-{ return this.type; }-*/;
	public final native String getRole() /*-{ return this.role; }-*/;
}