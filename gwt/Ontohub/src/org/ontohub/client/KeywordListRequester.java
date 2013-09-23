package org.ontohub.client;

import java.util.LinkedList;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.core.client.JsArray;
import com.google.gwt.core.client.JsonUtils;
import com.google.gwt.http.client.Request;
import com.google.gwt.http.client.RequestBuilder;
import com.google.gwt.http.client.RequestCallback;
import com.google.gwt.http.client.RequestException;
import com.google.gwt.http.client.Response;
import com.google.gwt.http.client.URL;
import com.google.gwt.user.client.rpc.AsyncCallback;

public class KeywordListRequester {

	public static class KeywordList extends LinkedList<Keyword>{

		/**
		 * Generated serial version
		 */
		private static final long serialVersionUID = 228642039907595010L;
	};

	public static class Keyword extends JavaScriptObject {
		protected Keyword() {}
		public final native String getText() /*-{ return this.text; }-*/; 
	}

	public static class OntologyList extends LinkedList<Ontology>{

		/**
		 * Generated serial version
		 */
		private static final long serialVersionUID = -3165438086598414639L;
	};

	public static class Ontology extends JavaScriptObject {
		protected Ontology() {}
		public final native String getName() /*-{ return this.name; }-*/;
		public final native String getAcronym() /*-{ return this.acronym; }-*/;
		public final native String getLanguage() /*-{ return this.language; }-*/;
		public final native String getLogic() /*-{ return this.logic; }-*/;
		public final native String getIri() /*-{ return this.iri; }-*/;
		public final native String getHref() /*-{ return this.url; }-*/; 
		public final native String getDescription() /*-{ return this.description; }-*/;
	}

	public void requestKeywordList(final String prefix, final AsyncCallback<KeywordList> keywordListCallback) {
		RequestBuilder builder = new RequestBuilder(RequestBuilder.GET, "ontologies/keywords");
		String requestData = "query=" + URL.encodeQueryString(prefix);
		try {
			builder.sendRequest(requestData, new RequestCallback() {
				@Override
				public void onError(Request request, Throwable exception) {
					keywordListCallback.onFailure(exception);
				}
				@Override
				public void onResponseReceived(Request request, Response response) {
					if (200 == response.getStatusCode()) {
						@SuppressWarnings("unchecked")
						JsArray<Keyword> array = (JsArray<Keyword>)JsonUtils.safeEval(response.getText());
						KeywordList keywordList = new KeywordList();
						for (int i = 0; i < (int)array.length(); i++) {
							Keyword keyword = array.get(i);
							keywordList.add(keyword);
						}
						keywordListCallback.onSuccess(keywordList);
					} else if (response.getStatusCode() != 0) {
						onError(request, new Exception());
					}
				}
			});
		} catch (RequestException exception) {
			keywordListCallback.onFailure(exception);
		}
	}

	public void requestOntologyList(final String[] keywordList, final AsyncCallback<OntologyList> keywordListCallback) {
		RequestBuilder builder = new RequestBuilder(RequestBuilder.GET, "ontologies/search");
		try {
			String requestData;
			StringBuffer requestDataBuffer = new StringBuffer();
			for (String keyword : keywordList) {
				requestDataBuffer.append("keyword[]=" + URL.encodeQueryString(keyword));
				requestDataBuffer.append("&");
			}
			if (keywordList.length > 0) {
				requestData = requestDataBuffer.toString().substring(0, requestDataBuffer.length() - 1);
			} else {
				requestData = "";
			}
			builder.sendRequest(requestData, new RequestCallback() {
				@Override
				public void onError(Request request, Throwable exception) {
					keywordListCallback.onFailure(exception);
				}
				@Override
				public void onResponseReceived(Request request, Response response) {
					if (200 == response.getStatusCode()) {
						@SuppressWarnings("unchecked")
						JsArray<Ontology> array = (JsArray<Ontology>)JsonUtils.safeEval(response.getText());
						OntologyList ontologyList = new OntologyList();
						for (int i = 0; i < (int)array.length(); i++) {
							Ontology ontology = array.get(i);
							ontologyList.add(ontology);
						}
						keywordListCallback.onSuccess(ontologyList);
					} else if (response.getStatusCode() != 0) {
						onError(request, new Exception());
					}
				}
			});
		} catch (RequestException exception) {
			keywordListCallback.onFailure(exception);
		}
	}

}
