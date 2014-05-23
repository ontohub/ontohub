package org.ontohub.shared;

import com.google.gwt.core.client.JavaScriptObject;

/**
 * Encapsulates the data for an image: location of image file (src) and text to display on hover (alt).
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class ImageData extends JavaScriptObject {
	protected ImageData() {}
	public final native String getSrc() /*-{ return this.src; }-*/;
	public final native String getAlt() /*-{ return this.alt; }-*/;
}
