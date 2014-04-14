package org.ontohub.shared;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.core.client.JsArray;

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
	public final native AnchorData getType() /*-{ return this.type; }-*/;
	public final native JsArray<AnchorData> getTopics() /*-{ return this.topics; }-*/;
	public final native JsArray<AnchorData> getProjects() /*-{ return this.projects; }-*/;
	public final native ImageData getIcon() /*-{ return this.icon; }-*/;
	public final AnchorData getTopic(int index) {
		JsArray<AnchorData> topics = getTopics();
		if (index < topics.length()) {
			return topics.get(index);
		} else {
			return null;
		}
	}
	public final AnchorData getProject(int index) {
		JsArray<AnchorData> projects = getProjects();
		if (index < projects.length()) {
			return projects.get(index);
		} else {
			return null;
		}
	}
}
