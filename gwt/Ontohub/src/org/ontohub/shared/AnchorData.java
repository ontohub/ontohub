package org.ontohub.shared;

import com.google.gwt.core.client.JavaScriptObject;

/**
 * Encapsulates the data for an anchor: the text to display and the address to load on navigation
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class AnchorData extends JavaScriptObject {
	protected AnchorData() {}
	public final native String getText() /*-{ return this.text; }-*/;
	public final native String getHref() /*-{ return this.href; }-*/;
}
