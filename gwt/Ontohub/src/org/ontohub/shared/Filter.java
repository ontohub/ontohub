package org.ontohub.shared;

import com.google.gwt.core.client.JavaScriptObject;

/**
 * A JSON object that describes a filter
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class Filter extends JavaScriptObject {
	protected Filter() {}
	public final native String getName() /*-{ return this.name; }-*/;
	public final native String getValue() /*-{ return this.value; }-*/;
	public final native int getCount() /*-{ return this.count; }-*/;
	public final String getCountLabel() {
		if (getValue() == null) {
			return "";
		} else {
			return " (" + getCount() + ")";
		}
	}
}
