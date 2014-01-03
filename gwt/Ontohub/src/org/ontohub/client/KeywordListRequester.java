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
		
		private final Integer page;
		private final Integer ontologiesPerPage;
		private final Integer ontologiesInSet;

		public OntologyList(Integer page, Integer ontologiesPerPage, Integer ontologiesInSet) {
			this.page = page;
			this.ontologiesPerPage = ontologiesPerPage;
			this.ontologiesInSet = ontologiesInSet;
		}

		public final Integer getPage() {
			return page;
		}

		public final Integer getOntologiesPerPage() {
			return ontologiesPerPage;
		}

		public final Integer getOntologiesInSet() {
			return ontologiesInSet;
		}

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

	public static class SearchResponse extends JavaScriptObject {
		protected SearchResponse() {}
		public final native int getPage() /*-{ return this.page; }-*/;
		public final native int getResultsInPage() /*-{ return this.resultsInPage; }-*/;
		public final native int getResultsInSet() /*-{ return this.resultsInSet; }-*/;
		public final native JsArray<Ontology> getResults() /*-{ return this.results; }-*/;
	}

	public void requestKeywordList(final String prefix, final AsyncCallback<KeywordList> keywordListCallback) {
		String requestData = "prefix=" + URL.encodeQueryString(prefix);
		RequestBuilder builder = new RequestBuilder(RequestBuilder.GET, "ontologies/keywords?" + requestData);
		builder.setHeader("Content-Type", "application/json");
		builder.setHeader("Accept", "application/json");
		try {
			builder.sendRequest(null, new RequestCallback() {
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

	public void requestOntologyList(final String[] keywordList, final int page, final AsyncCallback<OntologyList> keywordListCallback) {
		String requestData;
		StringBuffer requestDataBuffer = new StringBuffer();
		for (String keyword : keywordList) {
			requestDataBuffer.append("keywords[]=" + URL.encodeQueryString(keyword));
			requestDataBuffer.append("&");
		}
		requestDataBuffer.append("page=" + page);
		requestData = requestDataBuffer.toString();
		RequestBuilder builder = new RequestBuilder(RequestBuilder.GET, "ontologies/search?" + requestData);
		builder.setHeader("Content-Type", "application/json");
		builder.setHeader("Accept", "application/json");
		try {
			builder.sendRequest(null, new RequestCallback() {
				@Override
				public void onError(Request request, Throwable exception) {
					keywordListCallback.onFailure(exception);
				}
				@Override
				public void onResponseReceived(Request request, Response response) {
					if (200 == response.getStatusCode()) {
						@SuppressWarnings("unchecked")
						SearchResponse searchResponse = (SearchResponse)JsonUtils.safeEval(response.getText());
						JsArray<Ontology> array = searchResponse.getResults();
						OntologyList ontologyList = new OntologyList(searchResponse.getPage(),
								searchResponse.getResultsInPage(), searchResponse.getResultsInSet());
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
