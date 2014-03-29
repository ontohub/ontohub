package org.ontohub.shared;

import com.google.gwt.core.client.JavaScriptObject;

/**
 * A JSON object that describes an ontology keyword for search.
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class Keyword extends JavaScriptObject {
	protected Keyword() {}
	public final native static Keyword newInstance() /*-{ return {item: null, type: null, role: null}; }-*/;

	public final native void setItem(String item) /*-{ this.item = item; }-*/;
	public final native void setType(String type) /*-{ this.type = type; }-*/;
	public final native void setRole(String role) /*-{ this.role = role; }-*/;

	public final native String getItem() /*-{ return this.item; }-*/;
	public final native String getType() /*-{ return this.type; }-*/;
	public final native String getRole() /*-{ return this.role; }-*/;

	public final String toJson() {
		StringBuffer buffer = new StringBuffer();
		buffer.append("{\"item\":");
		buffer.append(escape(getItem()));
		buffer.append(",\"type\":");
		buffer.append(escape(getType()));
		buffer.append(",\"role\":");
		buffer.append(escape(getRole()));
		buffer.append("}");
		return buffer.toString();
	}

	private final static String escape(String string) {
		if (string == null) {
			return "null";
		}
		return "\"" +
			string
			.replace("\\", "\\\\")
			.replace("'",  "\\'")
			.replace("\"", "\\\"")
			.replace("&",  "\\&")
			.replace("\r", "\\r")
			.replace("\n", "\\n")
			.replace("\t", "\\t")
			.replace("\b", "\\b")
			.replace("\f", "\\f")
			+ "\"";
	}
}
