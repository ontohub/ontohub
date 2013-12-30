package org.ontohub.shared;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.core.client.JsArray;

/**
 * A JSON object that represents a map of filter arrays.
 * 
 * WARNING: The method "getWindowInstance" only works if there
 * is a JSON object in the window variable "FiltersMap".
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class FiltersMap extends JavaScriptObject {
	protected FiltersMap() {}
	public final native JsArray<Filter> getOntologyTypeFilters() /*-{ return this.OntologyType; }-*/;
	public final native JsArray<Filter> getProjectFilters() /*-{ return this.Project; }-*/;
	public final native JsArray<Filter> getFormalityLevelFilters() /*-{ return this.FormalityLevel; }-*/;
	public final native JsArray<Filter> getLicenseModelFilters() /*-{ return this.LicenseModel; }-*/;
	public final native JsArray<Filter> getTaskFilters() /*-{ return this.Task; }-*/;
	public final native static FiltersMap getWindowInstance() /*-{ return $wnd.FiltersMap; }-*/;
	public final native static boolean existsWindowInstance() /*-{ return $wnd.FiltersMap != undefined; }-*/;
}
