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
	public final native String getType() /*-{ return this.type; }-*/;
	public final native String getTypeUrl() /*-{ return this.typeUrl; }-*/;
	public final native String getTopic0() /*-{ return this.topic0; }-*/;
	public final native String getTopic1() /*-{ return this.topic1; }-*/;
	public final native String getTopic2() /*-{ return this.topic2; }-*/;
	public final native String getTopic0Url() /*-{ return this.topic0Url; }-*/;
	public final native String getTopic1Url() /*-{ return this.topic1Url; }-*/;
	public final native String getTopic2Url() /*-{ return this.topic2Url; }-*/;
	public final native String getProject0() /*-{ return this.project0; }-*/;
	public final native String getProject1() /*-{ return this.project1; }-*/;
	public final native String getProject2() /*-{ return this.project2; }-*/;
	public final native String getProject0Url() /*-{ return this.project0Url; }-*/;
	public final native String getProject1Url() /*-{ return this.project1Url; }-*/;
	public final native String getProject2Url() /*-{ return this.project2Url; }-*/;
	public final native String getIconUrl() /*-{ return this.iconUrl; }-*/;
	public final native String getIconAltText() /*-{ return this.iconAltText; }-*/;
}
