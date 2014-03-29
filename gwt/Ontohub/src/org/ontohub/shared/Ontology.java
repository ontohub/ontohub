package org.ontohub.shared;

import com.google.gwt.core.client.JavaScriptObject;

/**
 * A JSON object that describes an ontology for search results.
 *  
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class Ontology extends JavaScriptObject {
	protected Ontology() {}
	public final native String getName() /*-{ return this.name; }-*/;
	public final native String getAcronym() /*-{ return this.acronym; }-*/;
	public final native String getLanguage() /*-{ return this.language; }-*/;
	public final native String getLogic() /*-{ return this.logic; }-*/;
	public final native String getIri() /*-{ return this.iri; }-*/;
	public final native String getHref() /*-{ return this.url; }-*/; 
	public final native String getDescription() /*-{ return this.description; }-*/;
}
